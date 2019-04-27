use <Switch.scad> //modules for mx switch and key holes o
//use <Keycaps.scad>


//TODOs
/* 
 1) Palm Mount
 2) MCU Mount
 3) Base Mount
      a) on palm rest
      b) by the pinkie column
 4) trackball structure
 5) pretty boarder for final print
*/

$fn = 32;  
//-----  Alias

R0 = 0; //bottom row
R1 = 1;
R2 = 2;
R3 = 3;
R4 = 4;
R5 = 5;

C0 = 0; //Column
C1 = 1;
C2 = 2;
C3 = 3;
C4 = 4;
C5 = 5;
C6 = 6;
T0 = 7; //Thumb

IN     = 0; //inner path 
OUT    = 1; //outter path
PATH   = 0; //path function
NORMAL = 1; //path normal

//Modulation Reference
FRONT  =  1;
RIGHT  = -1;
BACK   = -1;
LEFT   =  1; 
TOP    =  1;
BOTTOM = -1;

//------   physical parameters
unit           = 18.05;
Tol            = 0.001;  // tolance
HullThickness  = 0.0001; // modulation hull thickness
TopHeight      = 0;      // Reference Origin of the keyswitch 
BottomHeight   = 3.6;    // height adjustment used for R0 keys for cherry types

SwitchWidth    = 15.6;   // switch width 
PlateOffsets   = 2.5;    // additional pading on width of plates
PlateOffsetsY  = 2.5;    // additional padding on lenght of plates
PlateThickness = 3.5;    // switch plate thickness  H_1st
PlateDimension = [SwitchWidth+PlateOffsets, SwitchWidth+PlateOffsetsY, PlateThickness];
PlateHeight    = 6.6;    //
SwitchBottom   = 4.8;    // from plate 

WebThickness   = 2;      // inter column hull inward offsets, 0 thickness results in poor plate thickness
dMount         = 5.1054; // mounting bore size
dChamfer       = 6;      // chamfer diameter
cutLen         = 0;    //3.2scut length for clipped khail 
cutLenM  = cutLen+1; // fudging 

Bthickness  = PlateDimension[0]-3;
BFrontHeight = 6;
BBackHeight  = 3;

tenting      = [0,15,0]; // tenting for enclusoure  
plateHeight  = 23;       // height adjustment for enclusure 
//-------  finger parametes and rule

//structure to hold column origin transformation
ColumnOrigin = [//[translation vec] [rotation vec1] [rotation vec2]
                [[  -48,   -unit*3/4,  0], [0, 0,   0], [ 0, 90,  0]], //INDEX 1 
                [[  -36,     -unit/2,  0], [0, 0,   0], [ 0, 90,  0]], //INDEX 2 knuckle
                [[  -18,     -unit/2,  0], [0, 0,   0], [ 0, 90,  0]], //INDEX 3 knuckle
                [[    0,           0,  0], [0, 0,   0], [ 0, 90,  0]], //MIDDLE knuckle
                [[   18,     -unit/2,  0], [0, 0,  -0], [ 0, 90,  0]], //RING knuckle
                [[ 32.0,   -unit*9/8,  0], [0, 0, -15], [ 0, 90,  0]], //PINKY 1 knuckle
                [[ 49.0, -unit*9/8-1, -3], [0, 0, -15], [ 0, 90,  0]], //PINKY 2 knuckle
                [[   -6,         -68,  0], [0, 0,   0], [90,  0,  0]]  //Thumb wrist origin
               ];

// structure to pass to thumbplacement module
ThumbPosition = 
 [//[[thetaDist, thetaMed, thetaProx, phiProx][rotation angle][rotation angle2][translation vec], clipLen, clip orientation] 
    [[-33,-22, 8.5],[ 0,-130, 15]], //R0
    [[-36,-22, -14],[15, -60,  0]], //R1
    [[-44, -3,  -9.8],[40, -60, -0]]  //R2 43
 ];

//-------  design and adjustment parameters 
//Angles used in the pathfunction  
//               i1   i2   i3    m     r    p1   p2
KeycapOffset = [  0,   0,   0,   0,    5,   2,    2]; //adjust path radius 

//Manual Adjustment of Pitches post Calculation for minor adjustment               
RowTrans     =[[    0,   .8,   .8,   .8,  .8,   .41,  .22,  0],  //R0
               [ 1.05, 1.95, 1.95, 1.95, 1.95, 1.60, 1.44,  1],  //R1s
               [  2.1, 2.36, 2.36, 2.36, 2.36, 1.58, 1.75,  2],  //R2s 
               [    3,    3,    3,    3,    3,    3,    3,  3],  //R3
               [    0,    0,    4,   -4,   -4,    4,   -4, -4],  //R4
               [    0,    0,    4,    4,   -4,    4,   -4,  4]   //R5
              ]*unit; 
              
Pitch        =[[    0,   15,  15,  15,  15,    10,  10,   0],  //R0
               [  -10,  -15, -15, -15, -15,   -15, -15,   0],  //R1s
               [  -15,  -10, -10, -0, -0,     -10,   0,   0],  //R2s 
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R3
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R4
               [    0,    0,   0,   0,   0,     0,   0,   0]   //R5
              ];

Roll         =[[   10,    0,   0,   0,   0,    -5, -10,   0],  //R0
               [  -10,    0,   0,   0,   0,    -5, -10,   0],  //R1s
               [  -10,    0,   0,   0,   0,     0,   0,   0],  //R2s 
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R3
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R4
               [    0,    0,   0,   0,   0,     0,   0,   0]   //R5
              ];         
              
Height       =[[    0,    0,   0,   0,   0,     0, -.6,   0],  //R0
               [    0,    0,   0,   0,   0,   -.8,  -1,   0],  //R1s
               [ -2.3,   -3,  -3,  -3,  -3,    -3,  -2,   0],  //R2s 
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R3
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R4
               [    0,    0,   0,   0,   0,     0,   0,   0]   //R5
              ]; 
              
//Manual Adjustment of Pitches post Calculation for minor adjustment               
Clipped      =[[cutLen, cutLen,  cutLen,  cutLen,  cutLen, -cutLen,  cutLen,  cutLen],  //R0
               [cutLen,-cutLen, -cutLen, -cutLen, -cutLen, -cutLen,  cutLen,  cutLen],  //R1s
               [cutLen, cutLen,  cutLen,  cutLen,  cutLen,  cutLen, -cutLen, -cutLen],  //R2s 
               [cutLen, cutLen, -cutLen,  cutLen,  cutLen,  cutLen, -cutLen, -cutLen],  //R3
               [cutLen, cutLen,  cutLen, -cutLen, -cutLen,  cutLen, -cutLen, -cutLen],  //R4
               [cutLen, cutLen,  cutLen,  cutLen, -cutLen,  cutLen, -cutLen,  cutLen]   //R5
              ];

//Orientation of the clippede switches

ClippedOrientation = //if length-wise true 
              [[false,  true,  true,  true,  true, false, false,  true],  
               [false,  true,  true,  true,  true, false, false,  true],
               [false,  true,  true,  true,  true,  true, false, false],
               [false, false, false,  true,  true,  true, false, false],
               [false, false, false, false, false,  true, false,  true],
               [false, false, false, false, false,  true, false, false]
              ]; 
              

KeyOriginCnRm = [for( i= [C0:C6])[[0,BottomHeight+KeycapOffset[i],0], for(j = [R1:R4])[0,TopHeight+KeycapOffset[i],0]]];
//row and column loop setter
RMAX         = R1;  // Set max rows on columns
CStart       = C1;  // Set column to begin looping for the build
CEnd         = C6;  // Set column to end for the build

//#########  Supporting Modules for Main Builder Modules
function hadamard(a, b) = !(len(a) > 0) ? a*b : [ for (i = [0:len(a) - 1]) hadamard(a[i], b[i])]; // elementwise mult

//Convinient notation for hulling a cube by face/edge/point
module hullPlate(referenceDimensions = [0,0,0], offsets = [0,0,0], scalings = [1,1,1])
{ 
  x = offsets[0] == 0 ?  scalings[0]*referenceDimensions[0]:HullThickness;
  y = offsets[1] == 0 ?  scalings[1]*referenceDimensions[1]:HullThickness;
  z = offsets[2] == 0 ?  scalings[2]*referenceDimensions[2]:HullThickness;
  hullDimension = [x, y, z];
  
  translate(hadamard(referenceDimensions, offsets/2))translate(hadamard(hullDimension, -offsets/2))cube(hullDimension, center = true);
} 

//Convinient cube transferomation and hulling 
module modulate(referenceDimension = [0,0,0], referenceSide = [0,0,0], objectDimension = [0,0,0], objectSide = [0,0,0], Hull = false, hullSide = [0,0,0], scalings = [1,1,1]){
  if(Hull == false){
    translate(hadamard(referenceDimension, referenceSide/2))translate(hadamard(hadamard(objectDimension,scalings),objectSide/2))scale(scalings)cube(objectDimension, center = true);
  }else{
    color("red")translate(hadamard(referenceDimension,referenceSide/2))translate(hadamard(hadamard(objectDimension,scalings), objectSide/2))hullPlate(objectDimension, hullSide, scalings);
  }
}  

module PlaceColumnOrigin(Cn = C0) {
 translate(ColumnOrigin[Cn][0])rotate(ColumnOrigin[Cn][1])rotate([90,0,0])mirror([0,1,0])rotate(ColumnOrigin[Cn][2])children();
}

module OnPlateOrigin(Rm = R0, Cn = C0){
  translate((KeyOriginCnRm[Cn][Rm]+[0,PlateHeight+PlateThickness/2,0]))children();
}

//place child object on the target position with all transforms
module BuildRmCn(row, col) {
  PlaceColumnOrigin(col)
    translate([RowTrans[row][col],Height[row][col],0])
            rotate([90,90,Pitch[row][col]])
            rotate([0,Roll[row][col],0])
              children();
}

module OnThumb(thetaDist, thetaMed, thetaProx, phiProx, stick = false, stickDia = 2){ //stick = true to show stick representation of thumb placement
  phiMed = 20; // medial rotation 
  rotate([-90,0,0])rotate([-phiProx,-thetaProx,0]){
    if(stick == true)color("red")cylinder(d=stickDia, FingerLength[T0][0]);// base
    translate([0,0,FingerLength[T0][0]]){
      rotate([0,thetaMed,0])rotate([0,0,phiMed]){
        if(stick == true)color("blue")cylinder(d=stickDia,FingerLength[T0][1]);
        translate([0,0,FingerLength[T0][1]]){ //tip
          rotate([0,thetaDist ,0]){
            if(stick == true)color("green")cylinder(d=stickDia,FingerLength[T0][2]);
            rotate([90,0,0])translate([0,FingerLength[T0][2]/2,0]){
              children();
            }
          }
        }
      }
    }
  }
}

module PlaceOnThumb(Rn = R0){ //for thumb 
  translate(ThumbPosition[Rn][0])rotate(ThumbPosition[Rn][1])children(); 
}    

module BuildColumn(plateThickness, offsets, sides =TOP, col=0, rowInit = R0, rowEnd = RMAX){
  refDim   = PlateDimension +[0,0,offsets];
  buildDim = [PlateDimension[0], PlateDimension[1], plateThickness];
  
  module modPlateLen(Hulls = true, hullSides = [0,0,0], rows, cols){//shorthand call for length-wise clipping 
    modulate(refDim,[0,sign(Clipped[rows][cols]),sides], buildDim-[0,abs(Clipped[rows][cols]),0], [0,-sign(Clipped[rows][cols]),BOTTOM], Hull = Hulls, hullSide = hullSides);
    //use clip length sign to direct transform sides and adjust platle length rather than if else statement for more compact call 
  }
  
  module modPlateWid(Hulls = true, hullSides = [0,0,0], rows, cols){//shorthand call for Width-wise clipping
    modulate(refDim,[sign(Clipped[rows][cols]), 0, sides], buildDim-[abs(Clipped[rows][cols]),0,0], [-sign(Clipped[rows][cols]), 0, BOTTOM], Hull = Hulls, hullSide = hullSides);
  }
  
  for (row = [rowInit:rowEnd]){// Plate
    if (ClippedOrientation[row][col] == true){ //for length-wise Clip
      BuildRmCn(row, col)modPlateLen(Hulls = false, rows =row, cols = col);  
      if (row < rowEnd){//Support struct
        hull(){
          BuildRmCn(row, col)modPlateLen(Hulls = true, hullSides = [0,FRONT,0], rows = row, cols = col);
          BuildRmCn(row+1, col)modPlateLen(Hulls = true, hullSides = [0,BACK,0], rows = row+1, cols = col);
        }
      }
    }else { // for Width-wise Clip
      BuildRmCn(row, col)modPlateWid(Hulls = false, rows =row, cols = col);  
      if (row < rowEnd){//Support struct
        hull(){
          BuildRmCn(row, col)modPlateWid(Hulls = true, hullSides = [0,FRONT,0], rows = row, cols = col);
          BuildRmCn(row+1, col)modPlateWid(Hulls = true, hullSides = [0,BACK,0], rows = row+1, cols = col);
        }
      }
    }
  }
}

module BuildTopCuts(plateThickness, offsets, sides =TOP, col=0, rowInit = R0, rowEnd = RMAX){
  refDim   = PlateDimension +[0,0,offsets];
  buildDim = [PlateDimension[0], PlateDimension[1], plateThickness];
  
  //for fine tuning top cuts 
  cutAdjustment = 2; 
  function clipFudge(rows, cols) = abs(Clipped[rows][cols]) != 0 ? abs(Clipped[rows][cols])+cutAdjustment : 0; 
  
  module modPlateLen(Hulls = true, hullSides = [0,0,0], rows, cols){//shorthand call for length-wise clipping 
    modulate(refDim,[0,sign(Clipped[rows][cols]),sides], buildDim-[0,clipFudge(rows, cols),0], [0,-sign(Clipped[rows][cols]),TOP], Hull = Hulls, hullSide = hullSides);
    //use clip length sign to direct transform sides and adjust platle length rather than if else statement for more compact call 
  }
  
  module modPlateWid(Hulls = true, hullSides = [0,0,0], rows, cols){//shorthand call for Width-wise clipping
    modulate(refDim,[sign(Clipped[rows][cols]), 0, sides], buildDim-[clipFudge(rows, cols),0,0], [-sign(Clipped[rows][cols]), 0, TOP], Hull = Hulls, hullSide = hullSides);
  }
  
  for (row = [rowInit:rowEnd]){// Plate
    if (ClippedOrientation[row][col] == true){ //for length-wise Clip
      BuildRmCn(row, col)modPlateLen(Hulls = false, rows =row, cols = col); 
      if (row < rowEnd){//Support struct
        hull(){
          BuildRmCn(row, col)modPlateLen(Hulls = true, hullSides = [0,FRONT,0], rows = row, cols = col);
          BuildRmCn(row+1, col)modPlateLen(Hulls = true, hullSides = [0,BACK,0], rows = row+1, cols = col);
        } 
      }
    }else { // for Width-wise Clip
      BuildRmCn(row, col)modPlateWid(Hulls = false, rows =row, cols = col);  
      if (row < rowEnd){//Support struct
        hull(){
          BuildRmCn(row, col)modPlateWid(Hulls = true, hullSides = [0,FRONT,0], rows = row, cols = col);
          BuildRmCn(row+1, col)modPlateWid(Hulls = true, hullSides = [0,BACK,0], rows = row+1, cols = col);
        }
      }
    }
  }
}


//################ Main Builder ############################
module BuildTopPlate(keyhole = false, Mount = true, platethickness = 0)
{
  plateDim = PlateDimension +[0,0,0]; //adjust Plate Dimension parameter
  RScale = 1.5;
  //Submodules
  module modPlate(Hulls = true, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows, cols){//shorthand
    BuildRmCn(rows, cols)modulate(PlateDimension,[0,sign(Clipped[rows][cols]), sides],plateDim-[0,abs(Clipped[rows][cols]),-platethickness-thickBuff], [0,-sign(Clipped[rows][cols]),refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateT(Hulls = false, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows){//shorthand for thumb
    PlaceOnThumb(rows)modulate(PlateDimension,[0,sign(Clipped[rows][T0]), sides],plateDim-[0,abs(Clipped[rows][T0]),-platethickness-thickBuff], [0,-sign(Clipped[rows][T0]),refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateWid(Hulls = true, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows, cols){//shorthand call for Width-wise clipping
    BuildRmCn(rows, cols)modulate(PlateDimension,[sign(Clipped[rows][cols]), 0, sides], plateDim-[abs(Clipped[rows][cols]),0,-platethickness-thickBuff], [-sign(Clipped[rows][cols]), 0, refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateWidT(Hulls = false, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows){//shorthand call for Width-wise clipping
    PlaceOnThumb(rows)modulate(PlateDimension,[sign(Clipped[rows][T0]), 0, sides], plateDim-[abs(Clipped[rows][T0]),0,-platethickness-thickBuff], [-sign(Clipped[rows][T0]), 0, refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modBoarderLen(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, cols, scaling = [1,1,1]){
    BuildRmCn(rows, cols)modulate(PlateDimension+[0,-refClip*2,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-dimClip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }
  module modBoarderWid(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, cols, scaling = [1,1,1]){
    BuildRmCn(rows, cols)modulate(PlateDimension+[-refClip*2,0,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-Bthickness,-dimClip,height], [refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  } 
  module modBoarderLenT(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows,scaling = [1,1,1]){
    PlaceOnThumb(rows)modulate(PlateDimension+[0,-refClip*2,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-dimClip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }
  module modBoarderWidT(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, scaling = [1,1,1]){
    PlaceOnThumb(rows)modulate(PlateDimension+[-refClip*2,0,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-Bthickness,-dimClip,height], [refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }   
  //End of Submodules
  
  //Main builds
  difference(){
    union(){//SwitchPlate
      //build columns 
      for(cols = [CStart:CEnd]){// build Webs    
        BuildColumn(PlateDimension[2]+platethickness, 0, TOP, col = cols, rowInit = R0, rowEnd = R1); //builds plate 
      }
      //Pretty Boarder
      //Top side
      hull(){ //C1R0 Edge
        modBoarderLen(true,  BACK,  LEFT,       0, cutLenM,  BBackHeight, [LEFT,0,0], R0, C1);
        modBoarderWid(true, FRONT,  LEFT, cutLenM,       0,  BBackHeight, [0,BACK,0], R0, C1);   
      }
      hull(){
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,BACK,TOP],  R1, C1);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight, [0,FRONT,TOP], R0, C1);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight, [0,BACK,TOP],  R0, C1);   
        
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,BACK,BOTTOM],  R1, C1, [RScale,1,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight, [0,FRONT,BOTTOM], R0, C1, [RScale,1,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight, [0,BACK,BOTTOM],  R0, C1, [1,1,1]); 
      }
      hull(){
        modBoarderWid(true, BACK, LEFT, cutLenM,       0, BFrontHeight, [0,0,TOP],   R1, C1);   
        modBoarderWid(true, BACK, LEFT, cutLenM,       0, BFrontHeight, [0,0,BOTTOM],R1, C1, [RScale,1,1]);   
      }
      hull(){
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,FRONT,TOP], R1, C1);  
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [LEFT,0,TOP],  R1, C1);
      
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,FRONT,BOTTOM], R1, C1, [RScale,1,1]);  
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [LEFT,0,BOTTOM],  R1, C1, [1,RScale,1]);
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,TOP],    R1, C1);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,TOP],    R1, C2);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,TOP],    R1, C3);
      
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,BOTTOM], R1, C1, [1,RScale,1]);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,BOTTOM], R1, C2, [1,RScale,1]);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,BOTTOM], R1, C3, [1,RScale,1]);
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,TOP],    R1, C3);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,TOP],    R1, C4);
        
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,BOTTOM], R1, C3, [1,RScale,1]);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,BOTTOM], R1, C4, [1,RScale,1]);
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,TOP],R1, C4);
        modBoarderLen(true, FRONT,RIGHT, cutLenM,       0, BFrontHeight, [0,0,TOP],    R1, C5);
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [0,0,TOP],    R1, C6);
      
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM],R1, C4, [1,RScale,1]);
        modBoarderLen(true, FRONT,RIGHT, cutLenM,       0, BFrontHeight, [0,0,BOTTOM], R1, C5, [1,RScale,1]);
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [0,0,BOTTOM], R1, C6, [1,RScale,1]);      
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,0],R1, C4);
        modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [RIGHT,0,0],R0, C4);
        modBoarderLen(true, FRONT,RIGHT, cutLenM,       0, BFrontHeight, [LEFT,0,0], R1, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R1, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,0], R0, C5);
      }
      hull(){
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,TOP],R1, C6);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,TOP],R1, C6); 
      
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,BOTTOM],R1, C6, [1,RScale,1]);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,BOTTOM],R1, C6, [RScale,1,1]); 
      }
      hull(){
        modBoarderWid(true,     0,RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,TOP],     R1, C6);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,TOP],    R1, C6);
      
        modBoarderWid(true,     0,RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,BOTTOM], R1, C6, [RScale,1,1]);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,BOTTOM], R1, C6, [RScale,1,1]);
      }
      hull(){
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight, [0,BACK,TOP], R1, C6);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight, [0,FRONT,TOP],R0, C6);   
      
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R1, C6, [RScale,1,1]);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM],R0, C6, [RScale,1,1]);   
      }
      hull(){  
        modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,TOP], R0, C6);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,FRONT,TOP],R0, C6);   
              
        modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,BOTTOM], R0, C6, [RScale,1,1]);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,FRONT,BOTTOM],R0, C6, [RScale,1,1]);   
      }     
      
      //Bottom side
        modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C1);
        modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C2);
        //type A
        hull(){
          modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C2);
          modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C3);
          modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [LEFT,0,0], R0, C4);
        }
        //Type B
//        hull(){
//          modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [RIGHT,0,0],    R0, C2);
//          modBoarderWid(true, FRONT,RIGHT, cutLenM,       0,  BBackHeight, [0,BACK,0], R0, C2);
//        }  
//        hull(){
//          modBoarderWid(true, FRONT,RIGHT, cutLenM,       0,  BBackHeight, [0,BACK,0], R0, C2);
//          modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C3);   
//          modBoarderWid(true, FRONT,  LEFT, cutLenM,      0,  BBackHeight, [0,BACK,0], R0, C4); 
//        }
//        hull(){
//          modBoarderLen(true, BACK,    0,       0, cutLenM,  BBackHeight, [LEFT,0,0], R0, C4);
//          modBoarderWid(true,FRONT, LEFT, cutLenM,       0,  BBackHeight, [0,BACK,0],  R0, C4);
//        }  
        
      hull(){
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight, [0,0,0], R0, C4);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R1, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,0], R0, C5);
      }
      hull(){
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R0, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,0], R0, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R1, C5);
      }    
      hull(){
        modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R0, C5);
        modBoarderLen(true, BACK, RIGHT, cutLenM,       0, BBackHeight, [LEFT,0,0], R0, C5);
      }    
      hull(){
        modBoarderLen(false,BACK, RIGHT, cutLenM,    0, BBackHeight, [0,0,0], R0, C5);
        modBoarderLen(false,BACK,  LEFT, cutLenM,    0, BBackHeight, [0,0,0], R0, C6);
      }
      hull(){
        modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,0], R0, C6);
        modBoarderLen(true, BACK, LEFT, cutLenM,       0,  BBackHeight, [RIGHT,0,0],R0, C6);   
      }       
      
      //----- Thumb Section
      modPlateWidT(rows = R0);
      modPlateT(rows = R1);
      modPlateWidT(rows = R2);
      hull(){
        modPlateWidT(Hulls = true, hullSides = [BOTTOM,0,0], rows = R0);
        modPlateT(Hulls = true, hullSides = [TOP,0,0], rows = R1);
      }
      hull(){
        modPlateWidT(Hulls = true, hullSides = [0,RIGHT,0], rows = R2);
        modPlateT(Hulls = true, hullSides = [0,LEFT,0], rows = R1);
      }
      hull(){
        modPlateWidT(Hulls = true, hullSides = [BOTTOM,LEFT,0], rows = R0);
        modPlateWidT(Hulls = true, hullSides = [TOP,RIGHT,0], rows = R2);
        modPlateT(Hulls = true, hullSides = [TOP,LEFT,0], rows = R1);
      }
      
      //pretty thumb Boarder
        modBoarderLenT(false,FRONT, LEFT, cutLen,       0,  BBackHeight, [0,0,0], R0);  
      hull(){
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0,  BBackHeight, [LEFT,0,0], R0);  
        modBoarderWidT(true,    0, LEFT,       0,       0,  BBackHeight, [0,FRONT,0], R0);
      }
        modBoarderWidT(false,   0, LEFT,       0,       0,  BBackHeight, [0,0,0], R0);
      hull(){
        modBoarderWidT(true,    0, LEFT,       0,       0,  BBackHeight, [0,BACK,0], R0);
        modBoarderLenT(true, BACK, LEFT, cutLenM,       0,  BBackHeight, [LEFT,0,0], R0);   
      }
        modBoarderLenT(false,BACK, LEFT, cutLen,       0,  BBackHeight, [RIGHT,0,0], R0);   
      hull(){
        modBoarderLenT(true, BACK, LEFT, cutLen,       0,  BBackHeight, [RIGHT,0,0], R0);
        modBoarderLenT(true, BACK, LEFT,       0, cutLenM,  BBackHeight, [LEFT,0,0], R1);  
      }
        modBoarderLenT(false,BACK, LEFT,       0, cutLenM,  BBackHeight, [0,0,0], R1); 
      hull(){
        modBoarderLenT(true, BACK, LEFT,       0, cutLenM,  BBackHeight, [RIGHT,0,0], R1); 
        modBoarderWidT(true,FRONT,RIGHT, cutLenM,       0,  BBackHeight, [0,BACK,0], R1); 
      }
        modBoarderWidT(false, FRONT, RIGHT, cutLenM, 0,  BBackHeight, [0,0,0], R1); 
      hull(){
        modBoarderWidT(true,FRONT,RIGHT, cutLenM,       0,  BBackHeight, [0,FRONT,0], R1); 
        modBoarderWidT(true,FRONT,RIGHT,       0,       0,  BBackHeight, [0,BACK,0], R2); 
      }
        modBoarderWidT(false,FRONT,RIGHT,       0,       0,  BBackHeight, [0,0,0], R2); 
      hull(){
        modBoarderWidT(true,FRONT,RIGHT,       0,       0,  BBackHeight, [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT,RIGHT, cutLenM,  0,  BBackHeight, [RIGHT,0,0], R2); 
      }
        modBoarderLenT(false,FRONT,RIGHT, cutLenM,  0,  BBackHeight, [0,0,0], R2); 
      hull(){
        modBoarderWidT(true,FRONT,RIGHT,       0,       0,  BBackHeight, [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT,RIGHT, cutLenM,  0,  BBackHeight, [RIGHT,0,0], R2); 
      }
      hull(){
        modBoarderWidT(true,FRONT, LEFT,       0, cutLenM,  BBackHeight, [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT,RIGHT, cutLenM,       0,  BBackHeight, [LEFT,0,0], R2); 
      }
        modBoarderWidT(false,FRONT,LEFT,       0, cutLenM,  BBackHeight, [0,0,0], R2); 
      hull(){
        modBoarderWidT(true,FRONT, LEFT,       0, cutLenM,  BBackHeight, [0,BACK,0], R2); 
        modBoarderLenT(true,FRONT, LEFT,       0,       0,  BBackHeight, [LEFT,0,0], R1); 
      }
      hull(){
        modBoarderLenT(true,FRONT, LEFT,       0,       0,  BBackHeight, [LEFT,0,0], R1); 
        modBoarderLenT(true,FRONT, LEFT, cutLen,       0,  BBackHeight, [RIGHT,0,0], R0);  
      }
      
      //binding to Columns
      hull(){
        modBoarderWid(true, BACK, LEFT,cutLen, 0, BFrontHeight, [0,BACK,TOP], R1, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM, 0, BBackHeight, [0,FRONT,TOP], R0, C1);
        modBoarderLenT(false,FRONT,RIGHT, cutLenM,  0,  BBackHeight, [0,0,0], R2); 
      
        modBoarderWid(true, BACK, LEFT,cutLen, 0, BFrontHeight, [0,BACK,BOTTOM], R1, C1,[RScale,1,1]);
        modBoarderWid(true, FRONT, LEFT, cutLenM, 0, BBackHeight, [0,FRONT,BOTTOM], R0, C1,[RScale,1,1]);
      }
      hull(){
        modBoarderWidT(true,FRONT, LEFT,       0, cutLenM, BBackHeight,  [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT,RIGHT, cutLenM,       0, BBackHeight,  [LEFT,0,0],  R2); 
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,  [0,BACK,0],  R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,  [0,FRONT,0], R0, C1);
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,BACK,0],  R1, C1);
      }

      hull(){
        modBoarderWidT(true,FRONT,LEFT,       0, cutLenM,  BBackHeight, [LEFT,0,0], R2);
        modBoarderLen(true, BACK, 0, 0, cutLenM, BBackHeight, [LEFT,0,0], R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM, 0, BBackHeight, [0,BACK,0], R0, C1);
      }
      hull(){
        modBoarderWidT(true,FRONT, LEFT,       0, cutLenM,  BBackHeight, [0,BACK,0], R2); 
        modBoarderLenT(true,FRONT, LEFT,       0,       0,  BBackHeight, [LEFT,0,0], R1); 
        modBoarderLenT(true,FRONT, LEFT, cutLen,       0,  BBackHeight, [RIGHT,FRONT,0], R0);  
        modBoarderLen(true, BACK, 0, 0, cutLenM, BBackHeight, [0,BACK,0], R0, C1);
      }    
      hull(){
        modBoarderLenT(true,FRONT, LEFT, cutLen,       0,  BBackHeight, [RIGHT,FRONT,0], R0);  
        modPlateT(Hulls = true, hullSides = [TOP,FRONT,0], rows = R1);
        modBoarderLenT(true, BACK, LEFT, cutLen,       0,  BBackHeight, [RIGHT,0,BOTTOM], R0);
        modBoarderLenT(true, BACK, LEFT,       0, cutLenM,  BBackHeight, [LEFT,0,BOTTOM], R1);  
        modBoarderLen(true, BACK, 0, 0, cutLenM, BBackHeight, [RIGHT,BACK,0], R0, C1);
        
      }
    }
    // !!!CUTS
    union(){     
      if(keyhole == true){
        for(cols = [C2:C5]){
          for(rows = [R0:RMAX]){
            BuildRmCn(rows, cols){
              if(ClippedOrientation[rows][cols] == true){
                Keyhole(clipLength = Clipped[rows][cols]);
              }else {
                rotate([0,0,-90])Keyhole(clipLength = Clipped[rows][cols],cutThickness = 3);
              }
            }
          }     
        }  
        BuildRmCn(R0, C1)rotate([0,0,  0])Keyhole(clipLength = Clipped[R0][C1], cutThickness = 0);       
        BuildRmCn(R1, C1)rotate([0,0,  0])Keyhole(clipLength = Clipped[R1][C1]);
        BuildRmCn(R1, C6)rotate([0,0,-90])Keyhole(clipLength = Clipped[R1][C6]);    
        BuildRmCn(R0, C6)rotate([0,0,-90])Keyhole(clipLength = Clipped[R0][C6]);    
        
        //mount?
//        BuildRmCn(R2, C2)cylinder(d=3, 20, center = true);
        //thumb
        PlaceOnThumb(0)rotate([0,0,-90])Keyhole(clipLength = cutLen, cutThickness = 2);
        PlaceOnThumb(1)Keyhole(clipLength = cutLen, cutThickness = 2);
        PlaceOnThumb(2)rotate([0,0,-90])Keyhole(clipLength = -cutLen, cutThickness = 2);    
      
        //cuttting artifacts 
        for(cols = [CStart:CEnd]){
          BuildTopCuts(PlateDimension[2]+platethickness+8, 0, TOP, col = cols, rowInit = R0, rowEnd = R1);  
        }
//        modPlateWidT(sides = TOP, refSides = TOP,rows = R0);
//        modPlateT(sides = TOP, refSides = TOP, rows = R1);
//        modPlateWidT(sides = TOP, refSides = TOP, rows = R2);
      }
    }
  }
}

module BuildEnclosure(platethickness = 0)
{ 
  plateDim = PlateDimension +[0,0,1];
  //Submodules 
  module modPlate(Hulls = true, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows, cols){//shorthand
    BuildRmCn(rows, cols)modulate(PlateDimension,[0,sign(Clipped[rows][cols]), sides],plateDim-[0,abs(Clipped[rows][cols]),-platethickness-thickBuff], [0,-sign(Clipped[rows][cols]),refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateT(Hulls = false, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows){//shorthand for thumb
    PlaceOnThumb(rows)modulate(PlateDimension,[0,sign(Clipped[rows][T0]), sides],plateDim-[0,abs(Clipped[rows][T0]),-platethickness-thickBuff], [0,-sign(Clipped[rows][T0]),refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateWid(Hulls = true, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows, cols){//shorthand call for Width-wise clipping
    BuildRmCn(rows, cols)modulate(PlateDimension,[sign(Clipped[rows][cols]), 0, sides], plateDim-[abs(Clipped[rows][cols]),0,-platethickness-thickBuff], [-sign(Clipped[rows][cols]), 0, refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateWidT(Hulls = false, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows){//shorthand call for Width-wise clipping
    PlaceOnThumb(rows)modulate(PlateDimension,[sign(Clipped[rows][T0]), 0, sides], plateDim-[abs(Clipped[rows][T0]),0,-platethickness-thickBuff], [-sign(Clipped[rows][T0]), 0, refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modBoarderLen(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, cols){
    BuildRmCn(rows, cols)modulate(PlateDimension+[0,-refClip*2,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-dimClip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides);
  }
  module modBoarderWid(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, cols){
    BuildRmCn(rows, cols)modulate(PlateDimension+[-refClip*2,0,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-Bthickness,-dimClip,height], [refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides);
  } 
  module modBoarderLenT(Hulls = false, sides = 0, refSides = 0, clip = 0, height = 6, hullSides = [0,0,0], rows){
    PlaceOnThumb(rows)modulate(PlateDimension+[0,0,4], [refSides,sides, BOTTOM],plateDim+[clip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides);
  }
  module modBoarderWidT(Hulls = false, sides = 0, refSides = 0, clip = 0, height = 6, hullSides = [0,0,0], rows){
    PlaceOnThumb(rows)modulate(PlateDimension+[0,0,4], [refSides,sides, BOTTOM],plateDim+[0,-Bthickness+.2,height], [-refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides);
  }  
  module projectEnclusure(){
    hull(){
      rotate(tenting)translate([0,0,plateHeight])hull(){
        children([0:$children-1]);
      }
      linear_extrude(1)projection()rotate(tenting)translate([0,0,plateHeight])hull(){
        children([0:$children-1]);
      }
    }
  }
  // End of submodules
  
    projectEnclusure()modBoarderWid(true, BACK, LEFT, cutLenM,       0, BFrontHeight, [0,0,BOTTOM],     R1, C1);   
//  projectEnclusure(){
//    modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,FRONT,0], R1, C1);  
//    modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [LEFT,0,0],  R1, C1);
//  }
//  //type A
//  projectEnclusure(){
//    modBoarderLen(false,FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,0],    R1, C1);
//    modBoarderLen(false,FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,0],    R1, C2);
//    modBoarderLen(false,FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,0],    R1, C3);
//  }
//  projectEnclusure(){
//    modBoarderLen(false,FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,0],    R1, C3);
//    modBoarderLen(false,FRONT,    0,       0, cutLenM, BFrontHeight, [0,0,0],    R1, C4);
//  }
//  projectEnclusure(){
//    modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,0],R1, C4);
//    modBoarderLen(false,FRONT,RIGHT, cutLenM,       0, BFrontHeight, [0,0,0],    R1, C5);
//    modBoarderLen(false,FRONT, LEFT, cutLenM,       0, BFrontHeight, [0,0,0],    R1, C6);
//  }
//
//  projectEnclusure(){
//    modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,0],R1, C4);
//    modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [RIGHT,0,0],R0, C4);
//    modBoarderLen(true, FRONT,RIGHT, cutLenM,       0, BFrontHeight, [LEFT,0,0], R1, C5);
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R1, C5);
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,0], R0, C5);
//  }
//    modBoarderWid(false,    0,RIGHT,       0, cutLenM, BFrontHeight, [0,0,0],    R1, C6);
//  projectEnclusure(){
//    modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,0],R1, C6);
//    modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,0],R1, C6); 
//  }
//  projectEnclusure(){
//    modBoarderWid(true,    0, RIGHT,       0, cutLenM, BFrontHeight, [0,BACK,0], R1, C6);
//    modBoarderWid(true,    0, RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,0],R0, C6);   
//  }
//  projectEnclusure(){  
//    modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,0], R0, C6);
//    modBoarderWid(true,    0, RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,0],R0, C6);   
//  }     
//
//  //Bottom side
//    modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C1);
//    modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C2);
//    //type A
//    projectEnclusure(){
//      modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C2);
//      modBoarderLen(false, BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0],    R0, C3);
//      modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [LEFT,0,0], R0, C4);
//    }
//    
//  projectEnclusure(){
//    modBoarderLen(true,  BACK,    0,       0, cutLenM,  BBackHeight, [0,0,0], R0, C4);
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R1, C5);
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,0], R0, C5);
//  }
//  projectEnclusure(){
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R0, C5);
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,0], R0, C5);
//    modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R1, C5);
//  }    
//  projectEnclusure(){
//    modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight, [0,BACK,0], R0, C5);
//    modBoarderLen(true, BACK, RIGHT, cutLenM,       0, BBackHeight, [LEFT,0,0], R0, C5);
//  }    
//  projectEnclusure(){
//    modBoarderLen(false,BACK, RIGHT, cutLenM,    0, BBackHeight, [0,0,0], R0, C5);
//    modBoarderLen(false,BACK,  LEFT, cutLenM,    0, BBackHeight, [0,0,0], R0, C6);
//  }
//  projectEnclusure(){
//    modBoarderWid(true,    0, RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,0], R0, C6);
//    modBoarderLen(true, BACK, LEFT, cutLenM,       0,  BBackHeight, [RIGHT,0,0],R0, C6);   
//  }       

 //Thumb Section
  projectEnclusure(){
    modPlateWidT(Hulls = true, hullSides = [BOTTOM,LEFT,0], rows = R2);
    modBoarderWid(true, FRONT, LEFT,-cutLen, BFrontHeight, [0,BACK,BOTTOM], R1, C1);
  }
  projectEnclusure()modPlateWidT(Hulls = true, hullSides = [BOTTOM,0,0], rows = R2);
  projectEnclusure()modPlateT(Hulls = true, hullSides = [BOTTOM,0,0], rows = R1);
  
  projectEnclusure(){
    modPlateWidT(Hulls = true, hullSides = [BOTTOM,BACK,0], rows = R2);
    modPlateT(Hulls = true, hullSides = [BOTTOM,FRONT,0], rows = R1);
  }
  projectEnclusure(){
    modPlateWidT(Hulls = true, hullSides = [BOTTOM,FRONT,TOP], rows = R2);
    modPlateWidT(Hulls = true, hullSides = [BOTTOM,BACK,TOP], rows = R2);
    modPlateT(Hulls = true, hullSides = [BOTTOM,FRONT,TOP], rows = R1);
  }
  projectEnclusure(){
    modPlateWidT(Hulls = true, hullSides = [BOTTOM,LEFT,0], rows = R0);
    modBoarderLen(true, BACK,    0,       0, cutLenM, BBackHeight, [LEFT,0,BOTTOM],    R0, C2);
  }
  projectEnclusure(){
    modPlateWidT(Hulls = true, hullSides = [BOTTOM,0,BOTTOM], rows = R0);
    modPlateWidT(Hulls = true, hullSides = [TOP,0,BOTTOM], rows = R1);
  } 
  
  
  
//  projectEnclusure()modBoarderWidT(false, BACK, 0, -cutLen, height = 1, hullSides = [0,0,0], rows =R1);
//  projectEnclusure(){
//    modBoarderLenT(true, BACK, LEFT, -cutLen, height = 1, hullSides = [RIGHT,0,BOTTOM], rows =R0);
//    modBoarderWidT(true, BACK, 0,    -cutLen, height = 1, hullSides = [LEFT,BACK,BOTTOM], rows =R1);
//  }
//  #projectEnclusure(){
//    modBoarderLenT(true, BACK, LEFT, -cutLen, height = 1, hullSides = [RIGHT,BACK,0], rows =R0);
//    modBoarderWidT(true, BACK, 0,    -cutLen, height = 1, hullSides = [LEFT,BACK,0], rows =R1);
//  }  

//  rotate(tenting)translate([0,0,plateHeight]){
//    modBoarderLenT(false, BACK, LEFT, -cutLen, height = 1, hullSides = [0,0,0], rows =R0);
//    hull(){
//      modBoarderLenT(true, BACK, LEFT, -cutLen, height = 1, hullSides = [RIGHT,0,0], rows =R0);
//      modBoarderWidT(true, BACK, 0,    -cutLen, height = 1, hullSides = [LEFT,0,0], rows =R1);
//    }
//  }    
  
  //trackball
//    projectEnclusure(){
//    modBoarderWid(true, 0, LEFT, 0, BBackHeight, [0,BACK,BOTTOM], R0, C5);
//    modBoarderLen(true, BACK, 0, 0, BBackHeight, [LEFT,0,BOTTOM], R0, C5);  
//    modPlateWidT(Hulls = true, hullSides = [BOTTOM,0,BOTTOM], rows = R0);
//    modPlateWidT(Hulls = true, hullSides = [TOP,0,BOTTOM], rows = R1);
//  }          
} 

module mockPCB(thickness,offsets ){
  for(cols = [CStart:C4]){
    color("blue")PlaceColumnOrigin(cols)translate([25,offsets,0])rotate([90,0,0])cube([28,15,thickness],center = true);
  }
  color("blue")PlaceColumnOrigin(C5)translate([18,offsets+1,7.5])rotate([90,0,0])rotate([-10,0,0])cube([35,25,thickness],center = true);
}
//##################   Section E:: Main Calls    ##################
difference(){
  union(){
    rotate(tenting)translate([0,0,plateHeight])BuildTopPlate(keyhole = true, Mount = false, channel = false, platethickness =0);
//    BuildEnclosure(platethickness = -1);
//    rotate(tenting)translate([0,0,plateHeight])mockPCB(1, 3);
  }
}
  //caps
  rotate(tenting)translate([0,0,plateHeight]){
    BuildSet2();
    PlaceOnThumb(0)rotate([0,0,-90])Switch(colors = "Steelblue",clipLength = cutLen);
    PlaceOnThumb(1)Switch(colors = "Steelblue",clipLength = cutLen);
    PlaceOnThumb(2)rotate([0,0,90])Switch(colors = "Steelblue",clipLength = cutLen);
  }
//translate([4,-20,25])color("royalblue")sphere(d=40,$fn= 64);
//##################   Section F:: Key Switches and Caps   ##################  
module BuildSet2()
{
  for(cols = [C1:C6])
  {
    for(rows = [R0:R1])
    {
//      if ( (rows != R0 || cols != C1) ){
        BuildRmCn(rows, cols)
        if(ClippedOrientation[rows][cols] == true){Switch(colors = "Steelblue", clipLength = Clipped[rows][cols]);}
        else {rotate([0,0,-90])Switch(colors = "Steelblue", clipLength = Clipped[rows][cols]);}
//      }
    }
  }
}

module BuildSetCaps()
{
  for(cols = [CStart:CEnd])
  {
    for(rows = [R0:RMAX])
    {
      color()BuildRmCn(rows, cols)
        {translate([0,0,8.9])keycap(rows+cols*(RMAX+1), ClippedOrientation[rows][cols], Clipped[rows][cols]);}
    }
  }
}
