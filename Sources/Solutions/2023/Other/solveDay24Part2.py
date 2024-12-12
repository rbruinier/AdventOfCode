import z3

# these are the coordinates and velocities of the first 3 hailstones

# 368925240582247, 337542061908847, 298737178993847 @ 21, -126, -9
# 287668477092999, 306868689869154, 240173335647821 @ -21, -15, 29
# 172063062341522, 378381220662744, 223621999511007 @ -25, -38, -64

pos = [
    (368925240582247, 337542061908847, 298737178993847),
    (287668477092999, 306868689869154, 240173335647821),
    (172063062341522, 378381220662744, 223621999511007)
]

vel = [
    (21, -126, -9),
    (-21, -15, 29),
    (-25, -38, -64)
]

x = z3.Real('x')
y = z3.Real('y')
z = z3.Real('z')

vx = z3.Real('vx')
vy = z3.Real('vy')
vz = z3.Real('vz')

s = z3.Solver()

for i in range(len(pos)):
    t = z3.Real(f"t{i}")

    s.add(pos[i][0] + vel[i][0] * t == x + vx * t)
    s.add(pos[i][1] + vel[i][1] * t == y + vy * t)
    s.add(pos[i][2] + vel[i][2] * t == z + vz * t)

s.check()

m = s.model()

print(m[x] + m[y] + m[z])
print(m[vx] + m[vy] + m[vz])

print(m[x].as_long() + m[y].as_long() + m[z].as_long())
