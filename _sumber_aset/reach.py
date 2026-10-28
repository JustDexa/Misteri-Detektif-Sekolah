import json, numpy as np
from collections import deque
def check(name):
    d=json.load(open(f'build/maps/{name}.json'))
    W,H=d['size']; R=2
    gw,gh=W//R,H//R
    solid=np.zeros((gh,gw),bool)
    for x,y,w,h in d['colliders']:
        solid[max(0,y//R):(y+h)//R+1, max(0,x//R):(x+w)//R+1]=True
    # NPC bodies
    for n,(x,y) in d['npcs'].items():
        solid[(y-4)//R:(y+1)//R+1,(x-6)//R:(x+6)//R+1]=True
    # player box 10x6 at feet (feet = bottom center): inflate
    from scipy.ndimage import binary_dilation
    st=np.ones((4,7),bool)  # ~8px tall x 14px wide in 2px cells
    blk=binary_dilation(solid,st)
    blk[:2,:]=blk[-2:,:]=True; blk[:,:3]=blk[:,-3:]=True
    sx,sy=d['spawn']; s=(sy//R,sx//R)
    if blk[s]: print(name,'SPAWN BLOCKED')
    seen=np.zeros_like(blk); q=deque([s]); seen[s]=True
    while q:
        y,x=q.popleft()
        for dy,dx in((1,0),(-1,0),(0,1),(0,-1)):
            ny,nx=y+dy,x+dx
            if 0<=ny<gh and 0<=nx<gw and not blk[ny,nx] and not seen[ny,nx]:
                seen[ny,nx]=True;q.append((ny,nx))
    def near(x0,y0,x1,y1,pad=14):
        ys=slice(max(0,(y0-pad)//R),(y1+pad)//R); xs=slice(max(0,(x0-pad)//R),(x1+pad)//R)
        return seen[ys,xs].any()
    bad=[]
    for n,(x,y) in d['npcs'].items():
        if not near(x-6,y-6,x+6,y+2): bad.append('npc:'+n)
    for n,(x,y,w,h) in d['zones'].items():
        if not seen[y//R:(y+h)//R,x//R:(x+w)//R].any(): bad.append('zone:'+n)
    for n,o in d['objects'].items():
        x,y,w,h=o['rect']
        if not near(x,y,x+w,y+h): bad.append('obj:'+n)
    print(name,'OK' if not bad else bad)
for n in ['sekolah','taman','pasar','museum']: check(n)
