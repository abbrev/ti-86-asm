w = 40
h = 20

d = 130
t=20+7
suntheta = 180-360*t/24
phi = 23.45 * cos(360*(d-172)/365)

// put the sun at 0 longitude for higher performance
sunx = cos(phi)
REM suny = 0
sunz = sin(phi)

xmin = -180:xmax = 180
ymin = -90:ymax = 90
dx = (xmax - xmin)/w
dy = (ymin - ymax)/h

g = 0.5

for r=0 to h-1
	phi = ymax + dy * r
	cosphi = cos(phi): z = sin(phi)
	z_x_sunz = z * sunz
	
	for c=0 to w-1
		// we shift theta because we put the sun at 0 longitude
		theta = xmin + dx * c - suntheta
		
		x = cos(theta) * cosphi
		REM y = sin(theta) * cosphi
		
		// we'd need a "+ y * suny" if the sun weren't at 0 longitude.
		illum = x * sunx + z_x_sunz
		if illum > 0 then g = g + illum
		if g >= 1 then g = g - 1 else pxon(r,c)
	next c
next r
