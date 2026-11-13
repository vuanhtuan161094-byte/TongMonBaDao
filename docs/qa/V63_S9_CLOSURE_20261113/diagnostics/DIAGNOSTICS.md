# QA notes

- A fresh exact-SHA run on 6124758ad70fef66a51c0fd94d034b4f65122e89 (including VFX19 R2, preserved lab-only) used Start-Process -Wait, one official Godot process at a time. Import, D1, and S0–S9 exited 0; each suite stdout contains its PASS marker. Version/import/test stdout and stderr are archived in raw/.
- Godot emitted “Failed to read the root certificate store” on stderr during import and tests. This OS certificate-store warning did not change exit codes or markers.
- S9 used the Windows OpenGL Compatibility renderer on Intel Iris Plus and captured three real Godot Viewport frames after summon attack events. The hidden QA window is not physical mouse/desktop acceptance. Captures are sparse technical frames and do not satisfy owner visual approval.
- No Thread-not-joined, ObjectDB leak, RID leak, or GDScript parse error appeared in the valid S9 output.
- D4A/Warehouse remains the previously recorded baseline failure from workflow #42971666349; this S9 closure did not modify or rerun it.
- V6.3 and its release gate remain OFF. Candidate nodes remain gated. This is not a full release/playability PASS.