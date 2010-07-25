#include "colors.inc"
#include "metals.inc"
#include "textures.inc"
#include "glass.inc"
#include "skies.inc"

/**/
global_settings {
    ambient_light  1
    max_trace_level 14
//    radiosity {}
}
/**/

// ChamferedBox Macro
// e,w,n,s .. chamfer for top edges
// ne,se,sw,nw .. chamfers for side edges
#declare rt2 = 1.4142;
#macro ChamferedBox(x1,y1,z1, x2,y2,z2, e, s, w, n, ne, se, sw, nw)
    difference {
        box {
            <x1,y1,z1> <x2,y2,z2>
        }
        box {
            <x1-1,0,0><x2+1,n*2,1>
            rotate <-45,0,0>
            translate <0,y2-n/rt2,z2>
        }
        box {
            <x1-1,0,0><x2+1,s*2,1>
            rotate <-135,0,0>
            translate <0,y2,z1+s/rt2>
        }
        box {
            <0,0,z1-1><0,e*2,z2+2>
            rotate <45,0,0>
            translate <x2,y2-e/rt2,0>
        }
        box {
            <0,0,z1-1><0,e*2,z2+2>
            rotate <135,0,0>
            translate <x1+e/rt2,y2,0>
        }
        box {
            <0,y1-1,0><ne*2,y2+1,1>
            rotate <0,45,0>
            translate <x2-ne/rt2,0,z2>
        }        
        box {
            <0,y1-1,0><se*2,y2+1,1>
            rotate <0,135,0>
            translate <x2,0,z1+se/rt2>
        }        
        box {
            <0,y1-1,0><sw*2,y2+1,1>
            rotate <0,225,0>
            translate <x1+sw/rt2,0,z1>
        }        
        box {
            <0,y1-1,0><nw*2,y2+1,1>
            rotate <0,315,0>
            translate <x1,0,z2-nw/rt2>
        }        
    }
#end // ChamferedBox

// MyLens Macro
#macro MyLens(LensRadius,LensEdgeThickness,LensThickness) 
difference {
  intersection {
#declare MyLensSphereRadius = (pow(LensRadius,2) + pow(LensThickness/2-LensEdgeThickness/2,2))/(LensThickness-LensEdgeThickness);
    sphere {
      <0,0,MyLensSphereRadius-LensThickness/2> MyLensSphereRadius
    }
    sphere {
      <0,0,-MyLensSphereRadius+LensThickness/2> MyLensSphereRadius
    }
  }
  cylinder {
    <0,0,-LensThickness> < 0,0,LensThickness> LensRadius
    inverse
  }
}
#end // MyLens

#macro Screw()  
  difference {
    cylinder {
      <0,0,0> <0,0.01,0> 0.008
    }
    cylinder {
      <0,0.008,0> <0,0.011,0> 0.006
    }
    pigment { Gray20 } 
  }
#end


//#declare MyMetal = Brushed_Aluminum
#declare MyMetal = T_Chrome_4D

#declare PI = 3.141592654;
#declare PImil = 3141593; // millionths of PI
#declare PItrunc = 3.14;
#declare PImiltrunc = 3140000;
#declare Meg = 1000000;
// 10 units = 1 m, 1 unit = 10 cm, 0.1 unit = 1 cm, 0.01 unit = 1 mm
//
#declare CmPerUnit = 10;
#declare RingDiameter = 10;
#declare RingRadialThickness = 0.15;
#declare RingHeight = 0.3;
#declare OneCmAngle = 1/(CmPerUnit*RingDiameter/2); // radians for 1 cm linear 
#declare OneMmAngle = OneCmAngle/10;
#declare AngleStep = OneCmAngle/10; // 
#declare AngleEnd = AngleStep*20; // multiple of angle step  *******
#declare AngleStart = OneCmAngle/10; // 1 mm tick
#declare AngleRestart = 2*PItrunc-AngleStep*20; // multiple of angle step ********
#declare CmTickWidth = 0.004; // width of a cm hash
#declare CmTickHeight = 0.08; // 8 mm
#declare MmTickWidth = CmTickWidth/2;
#declare MmTickHeight = CmTickHeight/2;
#declare Angle = AngleStart;



//
// DEFINITIONS FOR DIAMETER STICK
//
#macro PlaceMeterStick(RotationAngle)
  translate <0, RingHeight, 0>
  rotate <0, RotationAngle, 0>
#end
union {
  union {
    object {
//      <-RingDiameter/2-.2,0,0> <RingDiameter/2+.2,0.2,0.1>
        ChamferedBox(-RingDiameter/2,0,0, RingDiameter/2,0.2,0.1, 0,0.01,0,0.01, 0.0,0.0,0.0,0.0)
    }
    object {
        ChamferedBox(-RingDiameter/2-0.2,-0.08,0, -RingDiameter/2,0.2,0.1, 0.0,0.01,0,0.01, 0.0,0.0,0.01,0.01)
    }
    object {
        ChamferedBox(RingDiameter/2,-0.08,0, RingDiameter/2+0.2,0.2,0.1, 0.01,0.01,0,0.01, 0.01,0.01,0.0,0.0)
    }
    texture {
      MyMetal
      normal {
        bumps 0.0001
        scale 0.01
      }
    }        
    texture {
      pigment {
        image_map {
          png "stickscale-a.png" 
          map_type 0
          interpolate 2
//          once
        }
        translate <-0.5,0,0>
        scale <RingDiameter+0.4,0.2,1.0>
      }
    } // end texture (image_map)


  } // union


  // the curved slides
  intersection {
    cylinder {
      <0,-RingHeight-.02,0> <0,0,0> RingDiameter/2+0.18
    }
    cylinder {
      <0,-RingHeight-.1,0> <0,.1,0> RingDiameter/2+0.0001
      inverse
    }
    object {
        ChamferedBox(-RingDiameter, -RingHeight-0.1,-0.15, RingDiameter, 0.1, 0.15,  0.01, 0.01, 0.01, 0.01, 0,0,0,0)
    }

    texture {
      MyMetal
      normal {
        bumps  0.0001
        scale  0.01
      }
    }
  }

  // the screws
  object {
    Screw()
    rotate <-90,0,0>
    translate <RingDiameter/2+0.04, -0.04, -0.15>
  }
  object {
    Screw()
    rotate <-90,0,0>
    translate <RingDiameter/2+0.14, -0.04, -0.15>
  }
  // set the angle of the stick
  PlaceMeterStick(80)
}

// 
// DEFINITIONS FOR THE PRIMARY RING
// 


lathe {
  linear_spline
  14,
  <RingDiameter/2-RingRadialThickness, 0>, 
  <RingDiameter/2-RingRadialThickness, RingHeight>, 
  <RingDiameter/2-0.01, RingHeight>,
  <RingDiameter/2, RingHeight-0.01>,

  <RingDiameter/2, RingHeight-0.02>
  <RingDiameter/2-0.005, RingHeight-0.02>
  <RingDiameter/2-0.005, RingHeight-0.03>
  <RingDiameter/2, RingHeight-0.03>

  <RingDiameter/2, 0.02>
  <RingDiameter/2-0.005, 0.02>
  <RingDiameter/2-0.005, 0.01>
  <RingDiameter/2, 0.01>

  <RingDiameter/2, 0>,
  <RingDiameter/2-RingRadialThickness, 0>

    texture {
      MyMetal
      normal {
        bumps 0.0015
        scale 0.003
      }
    }
     finish {
        phong 0.075
        ambient .1
        diffuse .1
        specular 1
        roughness .1
        reflection {
          .9
          metallic
        }
     }
    texture {
      pigment {
        image_map {
          png "ringscale-axx.png" 
          map_type 2
          interpolate 2
          once
        }
        translate <0,0,0>
        scale <1,0.3,1>
      }
    }
  rotate <0,90+360*(16.0/314.1),0>

}
lathe {
  linear_spline
  5,
  <RingDiameter/2-RingRadialThickness-.1, 0>, 
  <RingDiameter/2-RingRadialThickness-.1, RingHeight>, 
  <RingDiameter/2-RingRadialThickness, RingHeight>,
  <RingDiameter/2-RingRadialThickness, 0>,
  <RingDiameter/2-RingRadialThickness-.1, 0>

    texture {
      MyMetal
      normal {
        bumps 0.0015
        scale 0.003
      }
    }
    finish {
       phong 0.075
       ambient .1
       diffuse .1
       specular 1
       roughness .1
       reflection {
         .9
         metallic
       }
    }
}

// Ring Supports
#declare Index = 0;
#while(Index <= 12)

  cylinder {
    <0,0,0> <0,-.2,0> 0.05
    translate <RingDiameter/2 -0.1,0,0>
    rotate <0, 30*Index, 0>
    texture {
      MyMetal
      normal {
        bumps 0.0015
        scale 0.003
      }
    }
  }

  #declare Index = Index + 1;
#end


/**/
// the magnifier, etc.
#declare LensRadius = 0.15;
#declare LensEdge = 0.045;
#declare LensCenter = 0.105;
union {
    union {
        object { 
          MyLens(LensRadius, LensEdge, LensCenter) // 
          interior { 
            I_Glass
            caustics 2
          }
//          texture {T_Green_Glass}
          texture {T_Glass3}
        }
        lathe {
            linear_spline
            5
            <LensRadius,-1.1*LensEdge/2.0>
            <LensRadius,+1.1*LensEdge/2.0>
            <LensRadius+0.01,+1.1*LensEdge/2.0>
            <LensRadius+0.01,-1.1*LensEdge/2.0>
            <LensRadius,-1.1*LensEdge/2.0>
            rotate <90,0,0>
            texture { T_Chrome_4D }
        }
        cylinder { 
            <0,-LensRadius-0.01,0> <0,-LensRadius-0.01-LensRadius,0> 0.015
            texture { T_Chrome_4D }
        }
        sphere {
            <0,-LensRadius-0.01-LensRadius-0.01,0> 0.02
            texture { T_Chrome_4D }
        }
        translate <0,LensRadius+0.01+LensRadius+0.01,0>
        rotate <20, -16, 34>
        translate <0,LensRadius,0>
    } // union
    cylinder {
        <0,0,0> <0,LensRadius-0.01,0> 0.015
        texture { T_Chrome_4D }
    }
    cylinder {
        <0,-0.08,0> <0,0,0> LensRadius/1.2
        texture { T_Chrome_3C }
    }
    translate <0.083,-0.12,-RingDiameter/2 - 0.35>
} // union
/**/


// the environment (display case, room, etc.)

#declare BoxTop = 1.5;
#declare BoxBottom = -0.2;
#declare BoxFrameWidth = 0.12;
#declare BoxWidth = 11;
#declare RoomWidth = 50;
#declare RoomHeight = 20;
#declare FloorHeight = -8;
#declare LegWidth = 0.25;

// box floor
box {
  <-BoxWidth/2,BoxBottom,-BoxWidth/2> <BoxWidth/2,BoxBottom-.1,BoxWidth/2>
  pigment { color rgb <0.65, 0.65, 0.75> }
  rotate <-90,0,0>
    texture {
      pigment {
        image_map {
          png "cal-log.png" 
          map_type 0
          interpolate 2
          once
        }
        scale 0.8*<1,0.62,1>
        translate <-0.7,-5.35,0>
      }
    }
    texture {
      pigment {
        image_map {
          png "asset-tag.png" 
          map_type 0
          interpolate 2
          once
        }
        scale 0.3*<1,0.91,1>
        translate <0.3,-5.4,0>
      }
    }
  rotate <90,0,0>
} 

// glass box
#macro GlassSide()
    box {
        <-BoxWidth/2,BoxBottom+0.0001,0.00> <BoxWidth/2,BoxTop,0.01>
        interior { I_Glass }
        texture {T_Glass3}
    }          
#end // GlassSide

object {
    GlassSide()
    translate <0,0,BoxWidth/2>
}
// front glass
object {
    GlassSide()
    rotate <0,180,0>
    translate <0,0,-BoxWidth/2+.01>
}
object {
    GlassSide()
    rotate <0,90,0>
    translate <BoxWidth/2,0,0>
}
object {
    GlassSide()
    rotate <0,-90,0>
    translate <-BoxWidth/2,0,0>
}
// top
box {
    <-BoxWidth/2,BoxTop,-BoxWidth/2> <BoxWidth/2,BoxTop+0.01,BoxWidth/2>
    interior { I_Glass }
    texture {T_Glass3} 
}          

// Frame for the glass box
#macro BoxVertical()
    box {
        <0,BoxBottom-BoxFrameWidth,0> <BoxFrameWidth,BoxTop+BoxFrameWidth,BoxFrameWidth>
        pigment { color Gray20 }
    }          
#end // BoxVertical
object {
    BoxVertical()
    translate <BoxWidth/2,0,BoxWidth/2>
}
object {
    BoxVertical()
    translate <-BoxWidth/2-BoxFrameWidth,0,BoxWidth/2>
}
object {
    BoxVertical()
    translate <BoxWidth/2,0,-BoxWidth/2-BoxFrameWidth>
}
object {
    BoxVertical()
    translate <-BoxWidth/2-BoxFrameWidth,0,-BoxWidth/2-BoxFrameWidth>
}
// top frame
difference {
    box {
        <-BoxWidth/2-BoxFrameWidth,BoxTop,-BoxWidth/2-BoxFrameWidth><BoxWidth/2,BoxTop+BoxFrameWidth,BoxWidth/2>
    }
    box {
        <-BoxWidth/2,-10,-BoxWidth/2>
        <BoxWidth/2,10,BoxWidth/2>
    }
    pigment { color Gray20 }
}
// bottom frame
difference {
    box {
        <-BoxWidth/2-BoxFrameWidth,BoxBottom,-BoxWidth/2-BoxFrameWidth><BoxWidth/2,BoxBottom-BoxFrameWidth,BoxWidth/2>
    }
    box {
        <-BoxWidth/2,-10,-BoxWidth/2>
        <BoxWidth/2,10,BoxWidth/2>
    }
    pigment { color Gray20 }
}

// table leg
#macro TableLeg()
    box {
        <0,BoxBottom,0> <LegWidth,FloorHeight,LegWidth>
    }
#end //TableLeg

object {
    TableLeg()
    translate <BoxWidth/2-LegWidth,0,BoxWidth/2-LegWidth>
}
object {
    TableLeg()
    translate <BoxWidth/2-LegWidth,0,-BoxWidth/2>
}
object {
    TableLeg()
    translate <-BoxWidth/2,0,-BoxWidth/2>
}
object {
    TableLeg()
    translate <-BoxWidth/2,0,BoxWidth/2-LegWidth>
}


// wall 5 m wide by 3 m high
#macro Wall(col)
    box {
      <-30,FloorHeight,0> <30,RoomHeight,0.1>
      pigment { color col }
    }
#end // Wall

/**/
object {
//  Wall(rgb <1.1,1,1>)
  Wall(Khaki)
  translate <0,0,RoomWidth/2>
}

object {
//  Wall(rgb <1,1.1,1>)
  Wall(PaleGreen)
  rotate <0,90,0>
  translate <RoomWidth/2,0,0>
}
object {
//  Wall(rgb <1,1,1.1>)
  Wall(Khaki)
  rotate <0,90,0>
  translate <-RoomWidth/2,0,0>
}
object {
//  Wall(rgb <1.1,1,1.1>)
  Wall(Khaki)
  translate <0,0,-RoomWidth/2>
}

// roof
box {
  <-RoomWidth/2-.1,RoomHeight,-RoomWidth/2-.2><RoomWidth/2+.1,RoomHeight+.1,RoomWidth/2+.1>
  pigment {color White}
}

// room floor
plane { //
  <0,1,0>, FloorHeight  // along the x-z plane (y is the normal vector)
  pigment { 
    checker color Gray20 color Gray30 
    scale <5,5,5>
  } // checkered pattern
}



#macro PanelLight(xpos, zpos, col)
  light_source {
    <0,0,0>
    color 4*col
    spotlight
    radius 25
    falloff 45
    tightness 0
    point_at <0,-1,0>
    looks_like { 
        box {
            <-2.5,0,-5> <2.5,0.1,5>
            pigment {color  rgb 1 }
            finish { ambient 5 }
        } 
    }
    translate <xpos, 19, zpos>
  }
#end // PanelLight

object {
    PanelLight(13,-13, rgb<1.05,1,1>)
}
object {
    PanelLight(13,13, rgb<1,1.05,1>)
}
object {
    PanelLight(-13,-13, rgb<1,1,1.05>)
}
object {
    PanelLight(-13,13, rgb<1.05,1,1.05>)
}



/**/
camera {

    // "close"
/**/
  location <-0.35,0.62,-5.9>
  look_at <.11,0.13,-RingDiameter/2-0.01>
/**/

    // "far"
/**
    location <-7, 5, -10>
    look_at <0.0,0.0,0.0>
**/
}

