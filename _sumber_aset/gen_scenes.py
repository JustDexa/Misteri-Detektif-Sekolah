"""Buat scenes/level1..4.tscn dari data peta JSON (node nyata yang bisa diedit di editor Godot)."""
import json

LEVELS = [('level1', 'sekolah', 'Level1Sekolah'), ('level2', 'taman', 'Level2Taman'),
          ('level3', 'pasar', 'Level3Pasar'), ('level4', 'museum', 'Level4Museum')]


def v2(x, y):
    def f(n):
        n = float(n)
        return str(int(n)) if n == int(n) else ('%g' % n)
    return f'Vector2({f(x)}, {f(y)})'


def build(script, mapname, rootname):
    d = json.load(open(f'game/assets/maps/{mapname}.json'))
    ext, sub, nodes = [], [], []

    def ext_res(typ, path):
        rid = f'{len(ext) + 1}_r'
        ext.append(f'[ext_resource type="{typ}" path="{path}" id="{rid}"]')
        return rid

    shapes = {}

    def shape(w, h):
        sid = f'Rect_{len(sub)}'
        sub.append(f'[sub_resource type="RectangleShape2D" id="{sid}"]\nsize = {v2(w, h)}')
        return sid

    s_id = ext_res('Script', f'res://scripts/{script}.gd')
    peta = ext_res('Texture2D', f'res://assets/maps/{mapname}_peta.png')
    atas = ext_res('Texture2D', f'res://assets/maps/{mapname}_atas.png')

    def node(name, typ, parent=None, props=()):
        head = f'[node name="{name}" type="{typ}"' + (f' parent="{parent}"' if parent is not None else '') + ']'
        nodes.append('\n'.join([head] + list(props)))

    node(rootname, 'Node2D', None, [f'script = ExtResource("{s_id}")'])
    node('Peta', 'Sprite2D', '.', [f'texture = ExtResource("{peta}")', 'centered = false'])
    node('Tabrakan', 'StaticBody2D', '.')
    for i, (x, y, w, h) in enumerate(d['colliders']):
        node(f'Kotak{i}', 'CollisionShape2D', 'Tabrakan',
             [f'position = {v2(x + w / 2, y + h / 2)}', f'shape = SubResource("{shape(w, h)}")'])
    node('Zona', 'Node2D', '.')
    for zid, (x, y, w, h) in d['zones'].items():
        node(zid, 'Area2D', 'Zona', [f'position = {v2(x + w / 2, y + h / 2)}', 'monitoring = false', 'monitorable = false'])
        node('Bentuk', 'CollisionShape2D', f'Zona/{zid}', [f'shape = SubResource("{shape(w, h)}")', 'debug_color = Color(0.99, 0.9, 0.3, 0.25)'])
    node('Benda', 'Node2D', '.')
    item_tex = {}
    for oid, o in d['objects'].items():
        x, y, w, h = o['rect']
        props = [f'position = {v2(x + w / 2, y + h / 2)}', 'monitoring = false', 'monitorable = false',
                 f'metadata/kind = "{o.get("kind", "inspect")}"']
        if o.get('item'):
            props.append(f'metadata/item = "{o["item"]}"')
        node(oid, 'Area2D', 'Benda', props)
        node('Bentuk', 'CollisionShape2D', f'Benda/{oid}', [f'shape = SubResource("{shape(w, h)}")', 'debug_color = Color(0.2, 0.9, 1, 0.3)'])
        if o.get('item'):
            it = o['item']
            if it not in item_tex:
                item_tex[it] = ext_res('Texture2D', f'res://assets/items/{it}.png')
            node('Ikon', 'Sprite2D', f'Benda/{oid}', [f'texture = ExtResource("{item_tex[it]}")', 'position = Vector2(0, -1)',
                                                   'modulate = Color(1, 1, 1, 0.6)'])
    node('Entities', 'Node2D', '.', ['y_sort_enabled = true'])
    for nid, (x, y) in d['npcs'].items():
        npc_shape = shape(12, 5)
        tex = ext_res('Texture2D', f'res://assets/chars/npc_{nid}.png')
        node(nid, 'Node2D', 'Entities', [f'position = {v2(x, y)}'])
        node('Sprite', 'Sprite2D', f'Entities/{nid}', [f'texture = ExtResource("{tex}")', 'centered = false',
                                                      'offset = Vector2(-8, -23)', 'hframes = 2'])
        node('Badan', 'StaticBody2D', f'Entities/{nid}')
        node('Bentuk', 'CollisionShape2D', f'Entities/{nid}/Badan', ['position = Vector2(0, -2.5)', f'shape = SubResource("{npc_shape}")'])
    node('SpawnPemain', 'Marker2D', '.', [f'position = {v2(*d["spawn"])}', 'gizmo_extents = 12.0'])
    node('Atas', 'Sprite2D', '.', ['z_index = 10', f'texture = ExtResource("{atas}")', 'centered = false'])

    out = [f'[gd_scene load_steps={len(ext) + len(sub) + 1} format=3]', ''] + ext + [''] + \
          ['\n'.join([x]) + '\n' for x in sub] + ['\n\n'.join(nodes), '']
    open(f'game/scenes/{script}.tscn', 'w').write('\n'.join(out))
    print(script, len(d['colliders']), 'kotak,', len(d['npcs']), 'npc,', len(d['objects']), 'benda,', len(d['zones']), 'zona')


for a in LEVELS:
    build(*a)
