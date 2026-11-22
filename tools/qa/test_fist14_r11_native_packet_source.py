from pathlib import Path
import json,hashlib
from PIL import Image
root=Path(__file__).resolve().parents[2]
p=json.loads((root/'docs/operations/vfx_packets/FIST14_R11_V4_PREFLIGHT.json').read_text())
assert p['skill_id']=='tmb.skill.fist.huyet_quyen.active_04.human'
assert p['declared_contract']['projectile_speed']==0
assert p['declared_contract']['target_limit']==1
assert p['time_contract']['runtime_receipt_timestamp']=='RUNTIME_MAPPING_PENDING'
assert [x['id'] for x in p['time_contract']['phases']]==['charge','peak','contact']
for spec in p['atlases']:
  im=Image.open(root/spec['path']).convert('RGBA')
  assert im.size==(spec['width'],spec['height'])
  hashes=[]
  for k in range(spec['frames']):
    i,j=k%spec['columns'],k//spec['columns']
    frame=im.crop((i*309,j*309,(i+1)*309,(j+1)*309))
    assert frame.getchannel('A').getextrema()[1]>0
    hashes.append(hashlib.sha256(frame.tobytes()).hexdigest())
  assert len(set(hashes))==len(hashes)
original=root/'godot/labs/combat_lab/fist14/r11_owner_review/source/FIST14_R11_ORIGINAL_OWNER_GIF.gif'
assert hashlib.sha256(original.read_bytes()).hexdigest()=='49ca2af9db90803a071fe629481be476cd15539b9a033eb3df3cfd6eb29b12dc'
print('FIST14_R11_PACKET_SOURCE_PASS: canonical fields, 3 atlases, 16 unique RGBA poses, original GIF immutable')
print('GODOT_NATIVE=NOT_RUN ACTOR_QUYEN_TU=NOT_VERIFIED GITHUB_HEAD=CHECK_CI_SHA')
