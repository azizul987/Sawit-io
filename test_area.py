import re

with open('Scene/main.tscn', 'r') as f:
    content = f.read()

polygons = re.findall(r'polygon = PackedVector2Array\((.*?)\)', content)
total_area = 0

for p in polygons:
    coords = [float(x.strip()) for x in p.split(',')]
    pts = [(coords[i], coords[i+1]) for i in range(0, len(coords), 2)]
    
    area = 0
    for i in range(len(pts)):
        p0 = pts[i]
        p1 = pts[(i+1) % len(pts)]
        area += (p0[0] * p1[1] - p0[1] * p1[0])
    
    area = abs(area * 0.5)
    print(f"Polygon area: {area}")
    total_area += area

print(f"Total Area: {total_area}")
