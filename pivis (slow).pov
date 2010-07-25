#include "colors.inc"
#include "textures.inc"
#include "glass.inc"


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

#declare MyMetal = Brushed_Aluminum
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

#declare CmTick = box {
  <-CmTickWidth/2,0,-0.01> <CmTickWidth/2,CmTickHeight,+0.001>  // .2 mm wide box
  texture{ pigment { color rgb <0,0,1> } }
}

#declare MmTick = box {
  <-MmTickWidth/2,0,-0.01> <MmTickWidth/2,MmTickHeight,0.001>
  texture { pigment { color rgb <0,0,1> } }
}

#declare StartTick = box {
  <-MmTickWidth/1,0,-0.01> <MmTickWidth/1,RingHeight, 0.001>
  texture { pigment { color rgb <1,0,0> } }
}


//
// DEFINITIONS FOR DIAMETER STICK
//
union {
  // the meter stick
  // ends
  union {
    box {
      <-RingDiameter/2-.2,0,0> <-RingDiameter/2,RingHeight,0.1>
    }
    box {
      <RingDiameter/2,0,0> <RingDiameter/2+.2,RingHeight,0.1>
    }
    texture {
      MyMetal
      normal {
        bumps 0.0001
        scale 0.01
      }
    }        
  }
  difference {
    union {
#declare MeterTickPos = -5;
#while (MeterTickPos < 5)
      box {
        <MeterTickPos,0,0> <MeterTickPos+.1,RingHeight,0.1> 
      }
#declare MeterTickPos = MeterTickPos + 0.1;
#end // while
      texture {
        MyMetal
        normal {  
          bumps 0.0001
          scale 0.01
        }
      }
    }
#declare MeterTickPos = -5;
#while (MeterTickPos <= 5)
    object {
      CmTick
      scale <1,1.5,1>
      translate <MeterTickPos,0,0>
    }
    text {
      ttf "timrom.ttf" concat(str((MeterTickPos+5)/10,0,2)," M") 0.05, 0
      pigment { Black }
      scale <0.04, 0.04, 1>
      rotate <0,0,90>
      translate <MeterTickPos+.001,0.15,-0.025>
    }

#declare MeterTickPos = MeterTickPos + 0.1;
#end // while
    translate <0, 0, -0.05>
  }
  // the curved slides
  intersection {
    cylinder {
      <0,-RingHeight,0> <0,0,0> RingDiameter/2+0.2
    }
    cylinder {
      <0,-RingHeight-.1,0> <0,.1,0> RingDiameter/2+0.0001
      inverse
    }
    box {
      <-RingDiameter, -RingHeight-.1, -.2> <RingDiameter, +.1, .2>
    }

    texture {
      MyMetal
      normal {
        bumps  0.0001
        scale  0.01
      }
    }
  }
  translate <0, RingHeight, 0>
  rotate <0, 80, 0>
}

// 
// DEFINITIONS FOR THE PRIMARY RING
// 
difference {
  cylinder { // 
    <0,0,0>  <0,RingHeight,0>  RingDiameter/2
    texture {
      MyMetal
      normal {
        bumps 0.0001
        scale 0.01
      }
    }
  }
  cylinder {
    <0,-1,0> <0,1,0> RingDiameter/2-RingRadialThickness
  }


// a single mark to indicate start/end
  object { StartTick
  }


#while (Angle <= 2*PI)

// CM ticks
#if (!mod(floor(1000*Angle+0.5),floor(1000*OneCmAngle+0.5)))
  object {
    CmTick
    translate <0,RingHeight/2-CmTickHeight/2,-RingDiameter/2>
    rotate <0,Angle*360/(2*PI),0>
  }
  
  text {
    ttf "timrom.ttf" concat(str(Angle*RingDiameter/20,0,2)," M") 0.1, 0 
    pigment { Black }
    scale <0.03, 0.03, 1>
    rotate <0,0,90>
    translate <0,0.2,-RingDiameter/2-0.05>
    rotate <0,Angle*360/(2*PI)-(0.001*20*360/(RingDiameter*2*PI)),0>
  }

#else 
#if (!mod(floor(1000*Angle+0.05),floor(1000*OneMmAngle+0.05)))
  object {
    MmTick
    translate <0,RingHeight/2-MmTickHeight/2,-RingDiameter/2>
    rotate <0,Angle*360/(2*PI),0>
  }
#end // if
#end // if

#declare Angle = Angle + AngleStep; // add a step
#if (Angle = AngleEnd) // don't do ticks around the back
  #declare Angle = AngleRestart; // re-start most of the way around 
#end // if
#end // while
}

object { 
  MyLens(0.1, 0.03, 0.07) // .1 radius, edge thick 3 mm, 7 mm center thicknessi
  interior { I_Glass }
  rotate <30,30,0>
  translate <-0.05, 0.2, -RingDiameter/2 - 0.15>
  texture {T_Green_Glass}
}

plane { // the floor
  <0,1,0>, -.5  // along the x-z plane (y is the normal vector)
  pigment { checker color Black color White } // checkered pattern
}


light_source { <10,10,-30> color rgb <1,1,1> }
light_source { <3,20,10> color rgb <1,1,1> }
light_source { <-3,20,10> color rgb <1,1,1> }


camera {
  location <-0.3,0.4,-5.6>
  look_at <.15,0.15,-5>
}

