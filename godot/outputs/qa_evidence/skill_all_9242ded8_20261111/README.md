# Raw QA evidence — code SHA 9242ded8

Godot 4.7.2 official (ed1daf0bf), isolated QA profile; not physical GUI acceptance.
- combined_matrix.csv: import, parse, 16 Poison V4 focused tests, 8 catalogue/school/PVB1 runtime tests, 3 mastery/legacy checks, and SaveService async roundtrip.
- matrix.csv, runtime_matrix.csv, extra_matrix.csv: per-test results.
- logs/ and runtime_logs/: raw stdout/stderr; save_service_async/ has the 10-check SaveService roundtrip.
- remote_inputs/ carries the exact-source D6 mastery/snapshot test copy fetched from code SHA 9242ded8.
- stderr includes the Windows root-certificate-store warning; listed test processes exited 0.