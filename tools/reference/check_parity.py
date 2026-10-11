"""Compare complete feature matrices through freshly built browser bindings."""
import argparse
import json
import subprocess
from pathlib import Path

import librosa
import numpy as np
import scipy

ROOT = Path(__file__).resolve().parents[2]


def cases():
    rng = np.random.default_rng(42)
    for name, fft, win, center, power, signal in [
        ("tone", 1024, 1024, True, 2.0, np.sin(2 * np.pi * 440 * np.arange(4000) / 16000)),
        ("silence", 512, 512, True, 2.0, np.zeros(1200)),
        ("noise", 512, 512, False, 2.0, rng.normal(0, 0.1, 1200)),
        ("short-window", 512, 200, True, 2.0, rng.normal(0, 0.1, 1200)),
        ("whisper-fft", 400, 400, True, 2.0, rng.normal(0, 0.1, 1200)),
        ("odd-fft", 255, 123, True, 2.0, rng.normal(0, 0.1, 1200)),
        ("magnitude", 256, 256, False, 1.0, rng.normal(0, 0.1, 1200)),
        ("single-sample", 512, 512, True, 2.0, np.array([0.1])),
    ]:
        yield name, dict(samples=signal.tolist(), sample_rate=16000, n_fft=fft,
                         hop_length=64, win_length=win, n_mels=24, n_mfcc=13,
                         center=center, power=power)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=ROOT / "tools/reference/parity_report.json")
    args = parser.parse_args()
    subprocess.run(["node", str(ROOT / "tools/build/sync-web.mjs")], cwd=ROOT, check=True)
    test_cases = list(cases())
    result = subprocess.run(["node", str(ROOT / "tools/reference/run-binding.mjs")],
                            input=json.dumps([c for _, c in test_cases]), text=True,
                            encoding="utf-8", capture_output=True, check=True, cwd=ROOT, timeout=60)
    actuals = json.loads(result.stdout)
    rows = []
    for (name, c), actual in zip(test_cases, actuals, strict=True):
        if not actual["success"]:
            raise AssertionError(f"{name}: {actual['error']}")
        signal = np.array(c["samples"])
        stft = np.abs(librosa.stft(signal, n_fft=c["n_fft"], hop_length=c["hop_length"],
                       win_length=c["win_length"], center=c["center"], pad_mode="reflect")) ** c["power"]
        fb = librosa.filters.mel(sr=c["sample_rate"], n_fft=c["n_fft"], n_mels=c["n_mels"],
                                fmin=0, fmax=8000, htk=False, norm="slaney", dtype=np.float64)
        mel = fb @ stft
        log_mel = librosa.power_to_db(mel, ref=1.0, amin=1e-10, top_db=80.0)
        mfcc = librosa.feature.mfcc(S=log_mel, n_mfcc=c["n_mfcc"], dct_type=2, norm="ortho")
        errors = {}
        for stage, expected in [("stft_preview", stft[actual["stft_bin_indices"]]),
                                ("mel", mel), ("log_mel", log_mel), ("mfcc", mfcc)]:
            measured = np.array(actual[stage])
            np.testing.assert_allclose(measured, expected, rtol=1e-7, atol=1e-7, err_msg=f"{name}/{stage}")
            errors[stage] = float(np.max(np.abs(measured - expected)))
        rows.append(dict(case=name, shape=[c["n_mels"], actual["n_frames"]], max_absolute_error=errors))
    report = dict(reference=dict(librosa=librosa.__version__, numpy=np.__version__, scipy=scipy.__version__),
                  convention="periodic Hann; reflect padding; Slaney filters float64; dB; orthonormal DCT-II",
                  scope="All Mel, Log-Mel and MFCC cells; up to 64 explicitly indexed STFT bins per frame. Eight deterministic signals/configurations. Not whole-library parity or a speed comparison.",
                  tolerance=dict(atol=1e-7, rtol=1e-7), passed=True, cases=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Parity passed: {len(rows)} cases. Report: {args.output}")


if __name__ == "__main__":
    main()
