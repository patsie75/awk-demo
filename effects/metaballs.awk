function init_metaballs() {
}

function do_metaballs(buf,    wi,he, t, A,C,D, x,y, c,G,H,J,K, i, u,v,U,V,X,Y,Z,p, h) {
  wi = int(buf["width"] / 2)
  he = int(buf["height"] / 2)

  t = elapsed * 3

  A = sin((t+90)*.5)  * 32
  B = sin((t+45)*1.2) * 16
  C = cos((t+33)*.7)  * 24
  D = cos((t+300)*.3) * 8
  E = sin((t+270)*.2) * 30
  F = cos((t+90)*.9)  * 32

  for(y=-he; y<=he; y++) {
    for(x=-wi; x<=wi; x++) {
      c = z = -5
      bx1 = x-(A-F)
      by1 = y-(B-E)/2
      bx2 = x-(B-D)
      by2 = y-(C-E)/2
      bx3 = x-(C-F)
      by3 = y-(D-A)/2
      bx4 = x-(D-C)
      by4 = y-(E-A)/2
      bx5 = x-(E-F)
      by5 = y-(F-B)/2
      bx6 = x-(F-A)
      by6 = y-(A-E)/2
      bx7 = x-(C-B)
      by7 = y-(F-D)/2
      bx8 = x-(E-C)
      by8 = y-(A-C)/2

      for (i=0; i++<3; z-=p/(Z?Z:1)) {
        u1 = bx1*bx1 + by1*by1 + z*z
        u2 = bx2*bx2 + by2*by2 + z*z
        u3 = bx3*bx3 + by3*by3 + z*z
        u4 = bx4*bx4 + by4*by4 + z*z
        u5 = bx5*bx5 + by5*by5 + z*z
        u6 = bx6*bx6 + by6*by6 + z*z
        u7 = bx7*bx7 + by7*by7 + z*z
        u8 = bx8*bx8 + by8*by8 + z*z
        U1 = u1*u1/2
        U2 = u2*u2/2
        U3 = u3*u3/2
        U4 = u4*u4/2
        U5 = u5*u5/2
        U6 = u6*u6/2
        U7 = u7*u7/2
        U8 = u8*u8/2

        if ( (84<=elapsed) && (elapsed<92) ) {
          X = bx1/U1
          Y = by1/U1
          Z = z/U1
          p = .005 - 1/u1
        }
        if ( (92<=elapsed) && (elapsed<100) ) {
          X = bx1/U1 + bx2/U2
          Y = by1/U1 + by2/U2
          Z = z/U1 + z/U2
          p = .01 - 1/u1 -1/u2
        }
        if ( (100<=elapsed) && (elapsed<108) ) {
          X = bx1/U1 + bx2/U2 + bx3/U3 + bx4/U4
          Y = by1/U1 + by2/U2 + by3/U3 + by4/U4
          Z = z/U1 + z/U2 + z/U3 + z/U4
          p = .02 - 1/u1 -1/u2 - 1/u3 - 1/u4
        }
        if ( (108<=elapsed) && (elapsed<124) ) {
          X = bx1/U1 + bx2/U2 + bx3/U3 + bx4/U4 + bx5/U5 + bx6/U6 + bx7/U7 + bx8/U8
          Y = by1/U1 + by2/U2 + by3/U3 + by4/U4 + by5/U5 + by6/U6 + by7/U7 + by8/U8
          Z = z/U1 + z/U2 + z/U3 + z/U4 + z/U5 + z/U6 + z/U7 + z/U8
          p = .03 - 1/u1 -1/u2 - 1/u3 - 1/u4 - 1/u5 - 1/u6 - 1/u7 - 1/u8
        }
      }

      if (p < 3e-4) {
        h = (X*C+Y*B-Z*13) / sqrt(X*X+Y*Y+Z*Z)
        c = int(wi+(h>0 ? h*h : 0))
      }

      buf[(x+wi),(y+he)] = sprintf("%d;%d;%d", clamp(c,0,255), clamp(c/2,0,255), clamp(c/4,0,255) )
    }
  }
}
