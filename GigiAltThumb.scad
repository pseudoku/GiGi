use <Switch.scad> //modules for mx switch and key holes o
use <sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/morphology.scad> //for cheaper minwoski 
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <skin.scad>  

//use <Keycaps.scad>

//TODOs
/* 
 1) Robust Rim Job
 2) MCU Mount
 3) pretty trackball structure
*/

$fn = 32;  
//-----  Alias

R0 = 0; //bottom row
R1 = 1;
R2 = 2;
R3 = 3;
PM = 3;
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

//------   Grid parameters
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
cutLen         = 0;        //3.4 scut length for clipped khail 
cutLenM        = cutLen+0; // fudging 

//-----    Enclusure and plate parameter
RScale         = 2;        //Rim bottom scaling
EScale         = 2.5;      //Enclosure bottom scaling

Bthickness     = PlateDimension[0]-2;  //thickness of the enclosure rim 
BFrontHeight   = 3;                    //Height of frontside of the enclosure rim 
BBackHeight    = 3;                    //Height of Backside of the enclosure rim 
T0Buffer       = 0;                    //Additional Plate thickness buffer for T0 position.

T0FrontH       = BFrontHeight + T0Buffer; //Adjusted height for T0 
T0BackH        = BBackHeight + T0Buffer;  //Adjuted height for T0

//-----     Tenting Parameters
tenting        = [0,0,0]; // tenting for enclusoure  
plateHeight    = 23.5;       // height adjustment for enclusure 


//-----     Trackball Parameters
trackR         = 17;        //trackball raidus  M570: 37mm, Ergo and Kennington: 40mm
trackOrigin    = [2,-25,7]; //trackball origin
trackTilt      = [0,0,0];    //angle for tilting trackpoint support and PCB

//-------  LAYOUT parameters

//structure to hold column origin transformation
ColumnOrigin = [//[translation vec] [rotation vec1] [rotation vec2]
                [[  -48,   -unit*3/4,  0], [0, 0,   0], [ 0, 90,  0]], //INDEX 1 
                [[  -36,     -unit/2,  0], [0, 0,   0], [ 0, 90,  0]], //INDEX 2 knuckle
                [[  -18,     -unit/4,  0], [0, 0,   0], [ 0, 90,  0]], //INDEX 3 knuckle
                [[    0,           0,  0], [0, 0,   0], [ 0, 90,  0]], //MIDDLE knuckle
                [[   18,     -unit/4,  0], [0, 0,  -0], [ 0, 90,  0]], //RING knuckle
                [[ 35.0,   -unit*5/8,  6], [0, 5, -15], [ 0, 90,  0]], //PINKY 1 knuckle
                [[ 52.0,   -unit*5/8, 10], [0,10, -15], [ 0, 90,  0]], //PINKY 2 knuckle
                [[   -0,          -0,  0], [0,-5,   0], [ 0,  0,  0]]  //Thumb wrist origin
               ];

// structure to pass to thumbplacement module
ThumbPosition = [//[translation vec] [rotation vec1] 
                  [[-29,-16, 2.9],[15, -60,  0]], //R0  original [[-33,-20, 8.5],[ 0,-130, 15]],
                  [[-36,-22, -14],[15, -60,  0]], //R1
                  [[-43, -3,-9.9],[40, -60, -0]], //R2 
                  [[-43, -3,-9.9],[40, -60, -0]]  //R3 
                ];

//-------  and adjustment parameters 
//
//              C0:i1 C1:i2 C2:i3  C3:m  C4:r C5:p1 C6:p2 T0:t  

RowTrans     =[[    0,   .8,   .8,   .8,   .8,  .45,  .45,   0],  //R0
               [ 1.05, 1.95, 1.95, 1.95, 1.95, 1.60, 1.60,   1],  //R1s
               [  2.1, 2.36, 2.36, 2.36, 2.36, 1.58, 1.75,   2],  //R2s 
               [    3,1.375,1.375,1.375,1.375,    1,  .83,   3],  //PCB Mount (PM)
               [    0,    0,    4,   -4,   -4,    4,   -4,  -4],  //R4
               [    0,    0,    4,    4,   -4,    4,   -4,   4]   //R5
              ]*unit; 
              
Pitch        =[[    0,   15,   15,   15,   15,   15,   15,   0],  //R0
               [  -10,  -15,  -15,  -15,  -15,  -15,  -15,   0],  //R1s
               [  -15,  -10,  -10,   -0,   -0,  -10,    0,   0],  //R2s 
               [    0,    0,    0,    0,    0,    0,    0,   0],  //R3
               [    0,    0,    0,    0,    0,    0,    0,   0],  //R4
               [    0,    0,    0,    0,    0,    0,    0,   0]   //R5
              ];

Roll         =[[   10,    0,   0,   0,   0,     0,   0,   0],  //R0
               [  -10,    0,   0,   0,   0,     0,   0,   0],  //R1s
               [  -10,    0,   0,   0,   0,     0,   0,   0],  //R2s 
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R3
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R4
               [    0,    0,   0,   0,   0,     0,   0,   0]   //R5
              ];         
              
Height       =[[    0,    0,   0,   0,   0,     0,   0,   0],  //R0
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R1s
               [ -2.3,   -3,  -3,  -3,  -3,    -3,  -2,   0],  //R2s 
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R3
               [    0,    0,   0,   0,   0,     0,   0,   0],  //R4
               [    0,    0,   0,   0,   0,     0,   0,   0]   //R5
              ]; 
              
//Manual Adjustment of Pitches post Calculation for minor adjustment               
Clipped      =[[cutLen, cutLen,  cutLen,  cutLen,  cutLen, -cutLen,  cutLen,  cutLen],  //R0
               [cutLen,-cutLen, -cutLen, -cutLen, -cutLen, -cutLen,  cutLen,  cutLen],  //R1s
               [cutLen, cutLen,  cutLen,  cutLen,  cutLen,  cutLen, -cutLen,  cutLen],  //R2s 
               [cutLen, cutLen, -cutLen,  cutLen,  cutLen,  cutLen, -cutLen, -cutLen],  //R3
               [cutLen, cutLen,  cutLen, -cutLen, -cutLen,  cutLen, -cutLen, -cutLen],  //R4
               [cutLen, cutLen,  cutLen,  cutLen, -cutLen,  cutLen, -cutLen,  cutLen]   //R5
              ];

//Orientation of the clippede switches
ClippedOrientation = //if length-wise true 
              [[false,  true,  true,  true,  true,  true,  true,  true],  
               [false,  true,  true,  true,  true,  true,  true,  true],
               [false,  true,  true,  true,  true,  true, false,  true],
               [false, false, false,  true,  true,  true, false, false],
               [false, false, false, false, false,  true, false,  true],
               [false, false, false, false, false,  true, false, false]
              ]; 
              
KeyOriginCnRm = [for( i= [C0:C6])[[0,BottomHeight],0], for(j = [R1:R4])[0,TopHeight,0]];
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
 rotate(ColumnOrigin[Cn][1])translate(ColumnOrigin[Cn][0])rotate([90,0,0])mirror([0,1,0])rotate(ColumnOrigin[Cn][2])children();
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


module PlaceOnThumb(Rn = R0){ //for thumb 
  translate(ColumnOrigin[T0][0])rotate(ColumnOrigin[T0][1])translate(ThumbPosition[Rn][0])rotate(ThumbPosition[Rn][1])children(); 
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
  if(col != T0){ // for column section 
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
  else if(col == T0){
    for (row = [rowInit:rowEnd]){// Plate
      if (ClippedOrientation[row][col] == true){ //for length-wise Clip
        PlaceOnThumb(row)modPlateWid(Hulls = false, rows =row, cols = col);  
      }else { // for Width-wise Clip
        PlaceOnThumb(row)modPlateLen(Hulls = false, rows =row, cols = col);
      }
    }
  }
}


//################ Main Builder ############################
module BuildTopPlate(keyhole = false,  trackball = false, platethickness = 0)
{
  plateDim = PlateDimension +[0,0,0]; //adjust Plate Dimension parameter
  //Submodules
  module modPlate(Hulls = true, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], row, col){//shorthand
    BuildRmCn(row, col)modulate(PlateDimension,[0,sign(Clipped[row][col]), sides],plateDim-[0,abs(Clipped[row][col]),-platethickness-thickBuff], [0,-sign(Clipped[row][col]),refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateWid(Hulls = true, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows, cols){//shorthand call for Width-wise clipping
    BuildRmCn(rows, cols)modulate(PlateDimension,[sign(Clipped[rows][cols]), 0, sides], plateDim-[abs(Clipped[rows][cols]),0,-platethickness-thickBuff], [-sign(Clipped[rows][cols]), 0, refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modBoarderLen(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, cols, scaling = [1,1,1]){
    BuildRmCn(rows, cols)modulate(PlateDimension+[0,-refClip*2,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-dimClip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }
  module modBoarderWid(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, cols, scaling = [1,1,1]){
    BuildRmCn(rows, cols)modulate(PlateDimension+[-refClip*2,0,platethickness*2], [refSides,sides, BOTTOM],plateDim+[-Bthickness,-dimClip,height], [refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }
  //same as above but for thumb
  module modPlateT(Hulls = false, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows){//shorthand for thumb
    PlaceOnThumb(rows)modulate(PlateDimension,[0,sign(Clipped[rows][T0]), sides],plateDim-[0,abs(Clipped[rows][T0]),-platethickness-thickBuff], [0,-sign(Clipped[rows][T0]),refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modPlateWidT(Hulls = false, thickBuff = 0, sides = TOP, refSides = BOTTOM, hullSides = [0,0,0], rows){//shorthand call for Width-wise clipping
    PlaceOnThumb(rows)modulate(PlateDimension,[sign(Clipped[rows][T0]), 0, sides], plateDim-[abs(Clipped[rows][T0]),0,-platethickness-thickBuff], [-sign(Clipped[rows][T0]), 0, refSides], Hull = Hulls, hullSide = hullSides);
  }
  module modBoarderLenT(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows,scaling = [1,1,1], Buffer = 0){
    PlaceOnThumb(rows)modulate(PlateDimension+[0,-refClip*2,platethickness*2+Buffer*2], [refSides,sides, BOTTOM],plateDim+[-dimClip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }
  module modBoarderWidT(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, scaling = [1,1,1], Buffer = 0){
    PlaceOnThumb(rows)modulate(PlateDimension+[-refClip*2,0,platethickness*2+Buffer*2], [refSides,sides, BOTTOM],plateDim+[-Bthickness,-dimClip,height], [refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }   
  //End of Submodules
  
  //Main builds
  difference(){
    union(){//SwitchPlate
      //build columns 
      for (cols = [CStart:CEnd]){// build Webs    
        BuildColumn(PlateDimension[2]+platethickness, 0, TOP, col = cols, rowInit = R0, rowEnd = R1); //builds plate 
        if (cols != CEnd && cols != C4){
          hull(){
            modPlate(false, sides = TOP, refSides = BOTTOM, hullSides = [RIGHT,0,0],row = R0,col = cols);
            modPlate(false,  sides = TOP, refSides = BOTTOM, hullSides = [RIGHT,0,0],row = R1,col = cols);
            modPlate(false,  sides = TOP, refSides = BOTTOM, hullSides = [LEFT,0,0],row = R0,col = cols+1);
            modPlate(false,  sides = TOP, refSides = BOTTOM, hullSides = [LEFT,0,0],row = R1,col = cols+1);
          }
        }
      }
      hull(){
        modPlate(false, sides = TOP, refSides = BOTTOM, hullSides = [RIGHT,0,0],row = R0,col = C4);
        modPlate(false,  sides = TOP, refSides = BOTTOM, hullSides = [RIGHT,0,0],row = R1,col = C4);
        modPlate(true,  sides = TOP, refSides = BOTTOM, hullSides = [LEFT,0,0],row = R1,col = C5);
      }     
      
      //Pretty Boarder
      //Top side
      hull(){ //C1R0 Edge
        modBoarderLen(true,  BACK, LEFT,       0, cutLenM,  BBackHeight,       [LEFT,0,TOP], R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,       [0,BACK,TOP], R0, C1);   
      
        modBoarderLen(true,  BACK, LEFT,       0, cutLenM,  BBackHeight,    [LEFT,0,BOTTOM], R0, C1, [1,RScale,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,    [0,BACK,BOTTOM], R0, C1, [RScale,1,1]);     
      }
      hull(){
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight,     [0,BACK,TOP], R1, C1);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,    [0,FRONT,TOP], R0, C1);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,     [0,BACK,TOP], R0, C1);   
        
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight,  [0,BACK,BOTTOM], R1, C1, [RScale,1,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight, [0,FRONT,BOTTOM], R0, C1, [RScale,1,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,  [0,BACK,BOTTOM], R0, C1, [RScale,1,1]); 
      }
      hull(){
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight,        [0,0,TOP], R1, C1);   
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight,     [0,0,BOTTOM], R1, C1, [RScale,1,1]);   
      }
      hull(){
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight,    [0,FRONT,TOP], R1, C1);  
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [LEFT,0,TOP], R1, C1);
      
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,FRONT,BOTTOM], R1, C1, [RScale,1,1]);  
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C1, [1,RScale,1]);
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,        [0,0,TOP], R1, C1);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,        [0,0,TOP], R1, C2);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,        [0,0,TOP], R1, C3);
      
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C1, [1,RScale,1]);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C2, [1,RScale,1]);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C3, [1,RScale,1]);
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,        [0,0,TOP], R1, C3);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,        [0,0,TOP], R1, C4);
        
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C3, [1,RScale,1]);
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C4, [1,RScale,1]);
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,    [RIGHT,0,TOP], R1, C4);
        modBoarderLen(true, FRONT,RIGHT, cutLenM,       0, BFrontHeight,        [0,0,TOP], R1, C5);
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight,        [0,0,TOP], R1, C6);
      
        modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C4, [1,RScale,1]);
        modBoarderLen(true, FRONT,RIGHT, cutLenM,       0, BFrontHeight,     [0,0,BOTTOM], R1, C5, [1,RScale,1]);
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight,     [0,0,BOTTOM], R1, C6, [1,RScale,1]);      
      }
      hull(){
        modBoarderLen(true, FRONT,    0,       0, cutLenM,BFrontHeight,      [RIGHT,0,0], R1, C4);
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,      [RIGHT,0,0], R0, C4);
        modBoarderLen(true, FRONT,RIGHT, cutLenM,       0,BFrontHeight,       [LEFT,0,0], R1, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,       [0,BACK,0], R1, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,      [0,FRONT,0], R0, C5);
      }
      hull(){
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0,BFrontHeight,    [RIGHT,0,TOP], R1, C6);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight,    [0,FRONT,TOP], R1, C6); 
      
        modBoarderLen(true, FRONT, LEFT, cutLenM,       0,BFrontHeight, [RIGHT,0,BOTTOM], R1, C6, [1,RScale,1]);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight, [0,FRONT,BOTTOM], R1, C6, [RScale,1,1]); 
      }
      hull(){
        modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R1, C6);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight,    [0,FRONT,TOP], R1, C6);
      
        modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R1, C6, [RScale,1,1]);
        modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight, [0,FRONT,BOTTOM], R1, C6, [RScale,1,1]);
      }
      hull(){
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R1, C6);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight,    [0,FRONT,TOP], R0, C6);   
       
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R1, C6, [RScale,1,1]);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C6, [RScale,1,1]);   
      }
      hull(){  
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R0, C6);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight,    [0,FRONT,TOP], R0, C6);   
              
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C6, [RScale,1,1]);
        modBoarderWid(true,    0, RIGHT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C6, [RScale,1,1]);   
      }     
      
      //Bottom side
      hull(){  
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [0,0,TOP], R0, C1);
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,     [0,0,BOTTOM], R0, C1, [1,RScale,1]);
      }
      hull(){  
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [0,0,TOP], R0, C2);
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,     [0,0,BOTTOM], R0, C2, [1,RScale,1]);
      }
      hull(){ 
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [0,0,TOP], R0, C2);
        modBoarderLen(false,BACK,     0,       0, cutLenM, BBackHeight,          [0,0,0], R0, C3);
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,       [LEFT,0,0], R0, C4);
             
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,     [0,0,BOTTOM], R0, C2, [1,RScale,1]);
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,  [LEFT,0,BOTTOM], R0, C4, [1,RScale,1]);
      }
      hull(){ 
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,        [0,0,TOP], R0, C4);
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,     [0,0,BOTTOM], R0, C4, [1,RScale,1]);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,       [0,BACK,0], R1, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,      [0,FRONT,0], R0, C5);
      }   
      hull(){
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R0, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,    [0,FRONT,TOP], R0, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R1, C5);
      
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C5, [RScale,1,1]);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C5, [RScale,1,1]);
      }    
      hull(){
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R0, C5);
        modBoarderLen(true,  BACK,RIGHT, cutLenM,       0, BBackHeight,     [LEFT,0,TOP], R0, C5);
        modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C5, [RScale,1,1] );     
        modBoarderLen(true,  BACK,RIGHT, cutLenM,       0, BBackHeight,  [LEFT,0,BOTTOM], R0, C5, [1,RScale,1]);  
      }    
      hull(){
        modBoarderLen(true, BACK,RIGHT, cutLenM,        0, BBackHeight,        [0,0,TOP], R0, C5);
        modBoarderLen(true, BACK, LEFT, cutLenM,        0, BBackHeight,        [0,0,TOP], R0, C6);        
        modBoarderLen(true, BACK,RIGHT, cutLenM,        0, BBackHeight,     [0,0,BOTTOM], R0, C5, [1,RScale,1]);
        modBoarderLen(true, BACK, LEFT, cutLenM,        0, BBackHeight,     [0,0,BOTTOM], R0, C6, [1,RScale,1]);      
      }
      hull(){
        modBoarderWid(true,    0,RIGHT,       0, cutLenM,  BBackHeight,    [0,BACK,TOP], R0, C6);
        modBoarderLen(true, BACK, LEFT, cutLenM,        0,  BBackHeight,   [RIGHT,0,TOP], R0, C6);   
      
        modBoarderWid(true,    0,RIGHT,       0, cutLenM,  BBackHeight, [0,BACK,BOTTOM], R0, C6, [RScale,RScale,1]);
        modBoarderLen(true, BACK, LEFT, cutLenM,       0,  BBackHeight,[RIGHT,0,BOTTOM], R0, C6, [1,RScale,1]);   
      }       
      
      //----- Thumb Cluster Section
      modPlateWidT(rows = R0,thickBuff = T0Buffer);
      modPlateWidT(rows = R1);
      modPlateWidT(rows = R2);
      
      hull(){
        modPlateWidT(Hulls = true, hullSides = [BOTTOM,0,0], rows = R0, thickBuff = T0Buffer);
        modPlateWidT(Hulls = true, hullSides = [TOP,0,0], rows = R1);
      }
      hull(){
        modPlateWidT(Hulls = true, hullSides = [0,RIGHT,0], rows = R2);
        modPlateWidT(Hulls = true, hullSides = [0,LEFT,0],  rows = R1);
      }
      hull(){
        modPlateWidT(Hulls = true, hullSides = [TOP,RIGHT,0], rows = R2);
        modPlateWidT(Hulls = true, hullSides = [TOP,LEFT,0],  rows = R1);
        modPlateWidT(Hulls = true, hullSides = [BOTTOM,LEFT,BOTTOM], rows = R0,thickBuff = T0Buffer);
        modBoarderWidT(true,BACK,LEFT, cutLenM, 0, BBackHeight, [0,BACK,BOTTOM], R2); 
      }
      hull(){
        modPlateWidT(Hulls = true, hullSides = [BOTTOM,LEFT,0], rows = R0,thickBuff = T0Buffer);
        modPlateWidT(Hulls = true, hullSides =   [TOP,RIGHT,0], rows = R2);
        modPlateWidT(Hulls = true,    hullSides =    [TOP,LEFT,0], rows = R1);
      }
      
      //pretty thumb Boarder
        modBoarderLenT(false,FRONT, LEFT, cutLen,       0,     T0BackH,      [0,0,0], R0, Buffer=T0Buffer);  
      hull(){
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0,     T0BackH,   [LEFT,0,0], R0, Buffer=T0Buffer);  
        modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,  [0,FRONT,0], R0, Buffer=T0Buffer);
      }
        modBoarderWidT(false,   0, LEFT,       0,       0,     T0BackH,      [0,0,0], R0, Buffer=T0Buffer);
      hull(){
        modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,   [0,BACK,0], R0, Buffer=T0Buffer);
        modBoarderLenT(true, BACK, LEFT, cutLenM,       0,     T0BackH,   [LEFT,0,0], R0, Buffer=T0Buffer);   
      }
        modBoarderLenT(false,BACK, LEFT,  cutLen,       0,     T0BackH,  [RIGHT,0,0], R0, Buffer=T0Buffer);
      hull(){
//        modBoarderLenT(true, BACK, LEFT,  cutLen,       0,     T0BackH,  [RIGHT,0,0], R0, Buffer=T0Buffer);
        modBoarderLenT(true,BACK, LEFT,  cutLen,        0,     T0BackH,  [0,BACK,0], R0, Buffer=T0Buffer);
        modBoarderLenT(true, BACK, LEFT, cutLenM,       0, BBackHeight,   [LEFT,0,0], R1);  
      }
        modBoarderLenT(false,BACK, LEFT, cutLenM,       0, BBackHeight,      [0,0,0], R1); 
      hull(){
        modBoarderLenT(true, BACK, LEFT, cutLenM,       0, BBackHeight,  [RIGHT,0,0], R1); 
        modBoarderWidT(true,FRONT,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,0], R1); 
      }
        modBoarderWidT(false,FRONT,RIGHT,      0, cutLenM, BBackHeight,      [0,0,0], R1); 
      hull(){
        modBoarderWidT(true,FRONT,RIGHT,       0, cutLenM, BBackHeight,  [0,FRONT,0], R1); 
        modBoarderWidT(true, BACK,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,0], R2); 
      }
        modBoarderWidT(false,BACK,RIGHT,       0, cutLenM, BBackHeight,      [0,0,0], R2); 
      hull(){
        modBoarderWidT(true,FRONT,RIGHT,       0, cutLenM, BBackHeight,[0,FRONT,TOP], R1); 
        modBoarderWidT(true, BACK,RIGHT,       0, cutLenM, BBackHeight, [0,BACK,TOP], R2); 
        modBoarderWidT(true, BACK,RIGHT,       0, cutLenM, BBackHeight,    [0,0,0], R2);       
      }   
      hull(){
        modBoarderWidT(true, BACK,RIGHT,       0, cutLenM, BBackHeight,  [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0, BBackHeight,  [RIGHT,0,0], R2); 
      }
        modBoarderLenT(false,FRONT,LEFT, cutLenM,       0, BBackHeight,       [0,0,0], R2); 
      hull(){
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,  [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0, BBackHeight,   [LEFT,0,0], R2); 
      }
        modBoarderWidT(false,BACK,LEFT,        0,       0, BBackHeight,      [0,0,0], R2); 
      hull(){
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,   [LEFT,0,0], R2);
        modBoarderLenT(true,FRONT, LEFT,  cutLen,       0,     T0BackH,      [0,0,0], R0, Buffer=T0Buffer);  
      }
//      
      //binding to Columns
      hull(){
        modBoarderWid(true,  BACK, LEFT,  cutLen,       0,BFrontHeight,    [0,BACK,TOP], R1, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,   [0,FRONT,TOP], R0, C1);
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0, BBackHeight,     [0,FRONT,0], R2); 
      
        modBoarderWid(true,  BACK, LEFT,  cutLen,       0,BFrontHeight, [0,BACK,BOTTOM], R1, C1,[RScale,1,1]);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,[0,FRONT,BOTTOM],R0, C1,[RScale,1,1]);
      }
      hull(){
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,     [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT,RIGHT,       0,       0, BBackHeight,      [LEFT,0,0], R2); 
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,      [0,BACK,0], R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,     [0,FRONT,0], R0, C1);
        modBoarderWid(true,  BACK, LEFT, cutLenM,       0,BFrontHeight,      [0,BACK,0], R1, C1);
      }
      hull(){
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,     [0,FRONT,0], R2); 
        modBoarderLenT(true,FRONT,RIGHT,       0,       0, BBackHeight,      [LEFT,0,0], R2); 
        
        modBoarderLen(true,  BACK, LEFT,       0, cutLenM,  BBackHeight,       [LEFT,0,TOP], R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,       [0,BACK,TOP], R0, C1);   
      
        modBoarderLen(true,  BACK, LEFT,       0, cutLenM,  BBackHeight,    [LEFT,0,BOTTOM], R0, C1, [1,RScale,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,    [0,BACK,BOTTOM], R0, C1, [RScale,1,1]);    
      }
      hull(){
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,    [LEFT,0,TOP], R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,      [0,BACK,0], R0, C1);
     
        modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight, [LEFT,0,BOTTOM], R0, C1,[1,RScale,1]);
      } 
      hull(){  
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,   [LEFT,FRONT,0], R2);
        modBoarderLenT(true,FRONT, LEFT,  cutLen,       0,     T0BackH,      [LEFT,0,0], R0, Buffer=T0Buffer);  
      
        modBoarderLen( true, BACK,    0,      0, cutLenM, BBackHeight,  [LEFT,BACK,TOP], R0, C1);
        modBoarderLen( true, BACK,    0,      0, cutLenM, BBackHeight,  [LEFT,BACK,TOP], R0, C2);
      
        modBoarderLen(true,  BACK,    0,      0, cutLenM, BBackHeight,  [LEFT,0,BOTTOM], R0, C1, [1,RScale,1]);
        modBoarderLen(true,  BACK,    0,      0, cutLenM,BBackHeight,[LEFT,BACK,BOTTOM], R0, C2, [1,RScale,1]);
      }

      hull(){
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0,     T0BackH,   [LEFT,0,0], R0, Buffer=T0Buffer);  
        modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,  [LEFT,FRONT,0], R0, Buffer=T0Buffer);
      
        modBoarderLen( true, BACK,    0,      0, cutLenM, BBackHeight,  [LEFT,BACK,TOP], R0, C2);
        modBoarderLen(true,  BACK,    0,      0, cutLenM,BBackHeight,[LEFT,BACK,BOTTOM], R0, C2, [1,RScale,1]);
      }
      
//      #hull(){ 
//        modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,  [LEFT,0,0], R0, Buffer=T0Buffer);
//      
//        modBoarderLen( true, BACK,    0,      0, cutLenM, BBackHeight,  [LEFT,BACK,TOP], R0, C2);      
//        modBoarderLen(true,  BACK,    0,      0, cutLenM,BBackHeight,[LEFT,BACK,BOTTOM], R0, C2, [1,RScale,1]);
//      }

      //additional clean up with bind to columns
      hull(){
        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0,     T0BackH,         [LEFT,0,0], R0, Buffer=T0Buffer);  
        modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,     [LEFT,FRONT,0], R0, Buffer=T0Buffer);
      
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,       [0,BACK,TOP], R0, C2);
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,    [0,BACK,BOTTOM], R0, C2, [1,RScale,1]);
      } 
      #hull(){
        modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,         [LEFT,0,0], R0, Buffer=T0Buffer);
      
        modBoarderLen( true, BACK,    0,       0, cutLenM, BBackHeight,   [RIGHT,BACK,TOP], R0, C2);
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,[RIGHT,BACK,BOTTOM], R0, C2, [1,RScale,1]);
      }  
      hull(){  
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,         [LEFT,0,0], R2);
        modBoarderLenT(true,FRONT, LEFT,  cutLen,       0,     T0BackH,            [0,0,0], R0, Buffer=T0Buffer);  
      
        modBoarderLen( true, BACK,    0,       0, cutLenM, BBackHeight,    [LEFT,BACK,TOP], R0, C1);
        modBoarderLen( true, BACK,    0,       0, cutLenM, BBackHeight,    [LEFT,BACK,TOP], R0, C2);
      
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,    [LEFT,0,BOTTOM], R0, C1, [1,RScale,1]);
        modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight, [LEFT,BACK,BOTTOM], R0, C2, [1,RScale,1]);
      }
      hull(){
        modBoarderWidT(true, BACK, LEFT,       0,       0, BBackHeight,         [0,0,0], R2);
        modBoarderLen(true,  BACK, LEFT,       0, cutLenM, BBackHeight,       [LEFT,0,TOP], R0, C1);
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,       [0,BACK,TOP], R0, C1);   
      
        modBoarderLen(true,  BACK, LEFT,       0, cutLenM, BBackHeight,    [LEFT,0,BOTTOM], R0, C1, [1,RScale,1]);  
        modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight,    [0,BACK,BOTTOM], R0, C1, [RScale,1,1]); 
      }
//      #hull(){
//        modBoarderLenT(true,FRONT, LEFT, cutLenM,       0, BBackHeight,            [0,0,0], R2); 
//      
//        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,      [0,BACK,TOP], R0, C1);   
//        modBoarderWid(true, FRONT, LEFT, cutLenM,       0,  BBackHeight,   [0,BACK,BOTTOM], R0, C1, [RScale,1,1]); 
//      }
      
      
      //Tarckballs
      if(trackball == true){
        hull(){  
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [RIGHT,0,TOP], R0, C2);
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,     [RIGHT,0,BOTTOM], R0, C2, [1,RScale,1]);
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,       [LEFT,0,0], R0, C4);
               
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,  [LEFT,0,BOTTOM], R0, C4, [1,RScale,1]);

          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [0,0,TOP], R0, C4);
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight ,    [0,0,BOTTOM], R0, C4, [1,RScale,1]);
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,       [0,BACK,0], R1, C5);
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,      [0,FRONT,0], R0, C5);
 
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R0, C5);
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,    [0,FRONT,TOP], R0, C5);
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R1, C5);
        
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C5, [RScale,1,1]);
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C5, [RScale,1,1]);

          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,     [0,BACK,TOP], R0, C5);
          modBoarderLen(true, BACK, RIGHT, cutLenM,       0, BBackHeight,     [LEFT,0,TOP], R0, C5);
          modBoarderWid(true,    0,  LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C5, [RScale,1,1] );     
          modBoarderLen(true, BACK, RIGHT, cutLenM,       0, BBackHeight,  [LEFT,0,BOTTOM], R0, C5, [1,RScale,1]);  
          
          modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,         [LEFT,BACK,0], R0, Buffer=T0Buffer);
          modBoarderLenT(true, BACK, LEFT, cutLenM,       0,     T0BackH,   [LEFT,0,0], R0, Buffer=T0Buffer);  
        }
        hull(){  
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [RIGHT,BACK,TOP], R0, C2);
          modBoarderLenT(true, FRONT, LEFT, cutLenM,       0,     T0BackH,   [LEFT,0,0], R0, Buffer=T0Buffer);  
          modBoarderLen(true, BACK, RIGHT, cutLenM,       0, BBackHeight,     [LEFT,0,TOP], R0, C5);    
          modBoarderWidT(true,    0, LEFT,       0,       0,     T0BackH,         [LEFT,0,0], R0, Buffer=T0Buffer);
          modBoarderLen(true, BACK,     0,       0, cutLenM, BBackHeight,        [RIGHT,BACK,TOP], R0, C4);
        }
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
        
        //PCB mount
//        for(cols = [CStart:CEnd])BuildRmCn(PM,cols)cylinder(d=3, 20, center = true);
        //thumb
        PlaceOnThumb(0)rotate([0,0,-90])Keyhole(clipLength = cutLen, cutThickness = 1);
        PlaceOnThumb(1)rotate([0,0,-90])Keyhole(clipLength = cutLen, cutThickness = 2);
        PlaceOnThumb(2)rotate([0,0,-90])Keyhole(clipLength = cutLen, cutThickness = 2);    
      
        //cuttting artifacts 
        for(cols = [CStart:CEnd]){
          BuildTopCuts(PlateDimension[2]+platethickness+8, 0, TOP, col = cols, rowInit = R0, rowEnd = R1);  
        }
        BuildTopCuts(PlateDimension[2]+platethickness+8, 0, TOP, col = T0, rowInit = R0, rowEnd = R2);  
      }
    }
  }
}

module BuildEnclosure(platethickness = 0, trackball = false, Jacks = false)
{ 
  plateDim = PlateDimension +[0,0,0];
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
  module modBoarderLenT(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows,scaling = [1,1,1], Buffer = 0){
    PlaceOnThumb(rows)modulate(PlateDimension+[0,-refClip*2,platethickness*2+Buffer*2], [refSides,sides, BOTTOM],plateDim+[-dimClip,-Bthickness,height], [-refSides,sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }
  module modBoarderWidT(Hulls = false, sides = 0, refSides = 0, dimClip = 0, refClip = 0, height = 6, hullSides = [0,0,0], rows, scaling = [1,1,1], Buffer = 0){
    PlaceOnThumb(rows)modulate(PlateDimension+[-refClip*2,0,platethickness*2+Buffer*2], [refSides,sides, BOTTOM],plateDim+[-Bthickness,-dimClip,height], [refSides,-sides,TOP], Hull = Hulls, hullSide = hullSides, scalings = scaling);
  }   
  module hullEnclusure(){
    hull(){
      rotate(tenting)translate([0,0,plateHeight])hull(){
        children([0:$children-1]);
      }
      linear_extrude(1)projection()rotate(tenting)translate([0,0,plateHeight])hull(){
        children([0:$children-1]);
      }
    }
  }
  module transEnclose(){
    rotate(tenting)translate([0,0,plateHeight]){
        children([0:$children-1]);
    }
  }
  module projectEnclose(){
    linear_extrude(1)projection()rotate(tenting)translate([0,0,plateHeight])hull(){
      children([0:$children-1]);
    }
  }
  // End of submodules
  difference(){
    union(){
      //TOP side
      hull(){
        transEnclose()modBoarderWid(true, BACK, LEFT, cutLenM,       0, BFrontHeight, [0,0,BOTTOM],R1, C1, [RScale,1,1]);   
        projectEnclose()modBoarderWid(true, BACK, LEFT, cutLenM,       0, BFrontHeight, [0,0,BOTTOM],R1, C1, [EScale,1,1]);
      }
      hull(){
        transEnclose(){
          modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,FRONT,BOTTOM], R1, C1, [RScale,1,1]);  
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C1, [1,RScale,1]);
        }
        projectEnclose(){
          modBoarderWid(true,  BACK, LEFT, cutLenM,       0, BFrontHeight, [0,FRONT,BOTTOM], R1, C1, [EScale,1,1]);  
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C1, [1,EScale,1]);      
        }
      }
      hull(){
        transEnclose(){
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C1, [1,RScale,1]);
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C3, [1,RScale,1]);
        }
        projectEnclose(){
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C1, [1,EScale,1]);
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,  [LEFT,0,BOTTOM], R1, C3, [1,EScale,1]);      
        }
      }
      hull(){
        transEnclose()
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C3, [1,RScale,1]);
        projectEnclose()
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,     [0,0,BOTTOM], R1, C3, [1,EScale,1]);
      }
      hull(){
        transEnclose(){ 
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C3, [1,RScale,1]);
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C4, [1,RScale,1]);
        }
        projectEnclose(){
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C3, [1,EScale,1]);
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C4, [1,EScale,1]);     
        }
      }
      hull(){
        transEnclose(){  
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight,    [RIGHT,0,TOP], R1, C4);
          modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight,    [RIGHT,0,TOP], R1, C6);
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C4, [1,RScale,1]);
          modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,BOTTOM], R1, C6, [1,RScale,1]);
        }
        projectEnclose(){
          modBoarderLen(true, FRONT,    0,       0, cutLenM, BFrontHeight, [RIGHT,0,BOTTOM], R1, C4, [1,EScale,1]);
          modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,BOTTOM], R1, C6, [1,EScale,1]);
        }
      }
      hull(){
        transEnclose(){    
          modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight,[RIGHT,FRONT,TOP], R1, C6);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight,[RIGHT,FRONT,TOP], R1, C6); 
          modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,BOTTOM], R1, C6, [1,RScale,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,BOTTOM], R1, C6, [RScale,1,1]); 
        }
        projectEnclose(){
          modBoarderLen(true, FRONT, LEFT, cutLenM,       0, BFrontHeight, [RIGHT,0,BOTTOM], R1, C6, [1,EScale,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BFrontHeight, [0,FRONT,BOTTOM], R1, C6, [EScale,1,1]); 
        }
      }
      hull(){
        transEnclose(){
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [RIGHT,BACK,TOP], R1, C6);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight, [RIGHT,FRONT,TOP], R1, C6);
      
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,BOTTOM], R1, C6, [RScale,1,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight,  [0,FRONT,BOTTOM], R1, C6, [RScale,1,1]);
        }
        projectEnclose(){  
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,BOTTOM], R1, C6, [EScale,1,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM,BFrontHeight,  [0,FRONT,BOTTOM], R1, C6, [EScale,1,1]);
        }
      }
      hull(){
        transEnclose(){
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight, [ RIGHT,BACK,TOP], R1, C6);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight, [RIGHT,FRONT,TOP], R0, C6);   
      
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,BOTTOM], R1, C6, [RScale,1,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [0,FRONT,BOTTOM], R0, C6, [RScale,1,1]);   
        }
        projectEnclose(){      
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,BOTTOM], R1, C6, [EScale,1,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [0,FRONT,BOTTOM], R0, C6, [EScale,1,1]);   
        }
      }
      hull(){
        transEnclose(){ 
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [RIGHT,BACK,TOP], R0, C6);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight, [RIGHT,FRONT,TOP], R0, C6);   
              
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,BOTTOM], R0, C6, [RScale,1,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [0,FRONT,BOTTOM], R0, C6, [RScale,1,1]);
        }
        projectEnclose(){  
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,   [0,BACK,BOTTOM], R0, C6, [EScale,1,1]);
          modBoarderWid(true,     0,RIGHT,       0, cutLenM, BBackHeight,  [0,FRONT,BOTTOM], R0, C6, [EScale,1,1]);
        }
      }     
          
      //Bottom side
      if (trackball == false){ 
        hull(){
          transEnclose(){       
            modBoarderLen(true,BACK,    0,       0, cutLenM,  BBackHeight,    [0,0,BOTTOM], R0, C2, [1,RScale,1]);
            modBoarderLen(true,BACK,    0,       0, cutLenM,  BBackHeight, [LEFT,0,BOTTOM], R0, C4, [1,RScale,1]);
          }
          projectEnclose(){ 
            modBoarderLen(true,BACK,    0,       0, cutLenM,  BBackHeight,    [0,0,BOTTOM], R0, C2, [1,EScale,1]);
            modBoarderLen(true,BACK,    0,       0, cutLenM,  BBackHeight, [LEFT,0,BOTTOM], R0, C4, [1,EScale,1]);
          }
        }
        hull(){
          transEnclose(){  
            modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,  [LEFT,0,BOTTOM], R0, C4, [1,RScale,1]);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C5);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R1, C5);
          }
          projectEnclose(){       
            modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight,  [LEFT,0,BOTTOM], R0, C4, [1,EScale,1]);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C5);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R1, C5);
          }
        }
        hull(){
          transEnclose(){  
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C5,[RScale,1,1]);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C5,[RScale,1,1]);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R1, C5);
          }
          projectEnclose(){
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R0, C5,[EScale,1,1]);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight, [0,FRONT,BOTTOM], R0, C5,[EScale,1,1]);
            modBoarderWid(true,     0, LEFT,       0, cutLenM, BBackHeight,  [0,BACK,BOTTOM], R1, C5);
          }
        }
        
        //thumb track section
        hull(){
          transEnclose(){  
            modBoarderLenT(true, FRONT, LEFT, cutLen,       0, BBackHeight, [RIGHT,FRONT,0], R0, Buffer = T0Buffer);
            
            modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight, [LEFT,BACK,TOP], R0, C2);
            modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight, [LEFT,0,BOTTOM], R0, C2, [1,RScale,1]);
          }
          projectEnclose(){
            modBoarderLenT(true, FRONT, LEFT, cutLen,       0, BBackHeight, [RIGHT,FRONT,0], R0, [EScale,1,1]);
            modBoarderLen(true,  BACK,    0,       0, cutLenM, BBackHeight, [LEFT,0,BOTTOM], R0, C2, [1,EScale,1]);        
          }
        }
        hull(){
          transEnclose(){ 
            modBoarderLenT(true,  BACK, LEFT, cutLen,       0,           2,     [RIGHT,0,0], R0, Buffer = T0Buffer);
            modBoarderLenT(true, FRONT, LEFT, cutLen,       0,           0,     [RIGHT,0,0], R0, Buffer = T0Buffer);
          }
          projectEnclose(){
            modBoarderLenT(true,  BACK, LEFT, cutLen,       0, BBackHeight,[RIGHT,0,0], R0, [EScale,EScale,1]);
            modBoarderLenT(true, FRONT, LEFT, cutLen,       0, BBackHeight,     [RIGHT,0,0], R0, [EScale,1,1]);
          }
        }
      }
      else{
       hull(){
          projectEnclose(){
            modBoarderLenT(true, BACK, LEFT, cutLen,       0, BBackHeight,    [LEFT,0,0], R0, [1,EScale,1]);
          }   
          transEnclose(){  
            modBoarderWid(true,    0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R0, C5,[RScale,1,1]);
            modBoarderLen(true, BACK,RIGHT, cutLenM,       0, BBackHeight, [LEFT,0,BOTTOM], R0, C5, [1,RScale,1]);  
            modBoarderLenT(true, BACK, LEFT, cutLen,       0, BBackHeight, [LEFT,BACK,0], R0);
          }    
          projectEnclose(){
            modBoarderWid(true,    0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R0, C5,[EScale,1,1]);
            modBoarderLen(true, BACK,RIGHT, cutLenM,       0, BBackHeight, [LEFT,0,BOTTOM], R0, C5, [1,EScale,1]);  
          }   
        }
     }
      
      hull(){
        transEnclose(){  
          modBoarderWid(true,    0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R0, C5,[RScale,1,1]);
          modBoarderLen(true, BACK,RIGHT, cutLenM,       0, BBackHeight, [LEFT,0,BOTTOM], R0, C5, [1,RScale,1]);  
        }    
        projectEnclose(){
          modBoarderWid(true,    0, LEFT,       0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R0, C5,[EScale,1,1]);
          modBoarderLen(true, BACK,RIGHT, cutLenM,       0, BBackHeight, [LEFT,0,BOTTOM], R0, C5, [1,EScale,1]);  
        }   
      }    
      hull(){
        transEnclose(){
          modBoarderLen(true,BACK, RIGHT, cutLenM,       0, BBackHeight, [0,BACK,TOP], R0, C5, [1,1,1]);
          modBoarderLen(true,BACK,  LEFT, cutLenM,       0, BBackHeight, [0,BACK,TOP], R0, C6, [1,1,1]); 
          modBoarderLen(true,BACK, RIGHT, cutLenM,       0, BBackHeight, [0,0,BOTTOM], R0, C5, [1,RScale,1]);
          modBoarderLen(true,BACK,  LEFT, cutLenM,       0, BBackHeight, [0,0,BOTTOM], R0, C6, [1,RScale,1]);      
        }
        projectEnclose(){
          modBoarderLen(true,BACK, RIGHT, cutLenM,       0, BBackHeight, [0,0,BOTTOM], R0, C5, [1,EScale,1]);
          modBoarderLen(true,BACK,  LEFT, cutLenM,       0, BBackHeight, [0,0,BOTTOM], R0, C6, [1,EScale,1]);      
        }
      }
      hull(){
        transEnclose(){
          modBoarderWid(true,    0, RIGHT,      0, cutLenM, BBackHeight, [0,BACK,TOP], R0, C6);
          modBoarderLen(true, BACK, LEFT, cutLenM,       0, BBackHeight, [RIGHT,0,TOP], R0, C6);   
      
          modBoarderWid(true,    0, RIGHT,      0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R0, C6, [RScale,RScale,1]);
          modBoarderLen(true, BACK, LEFT, cutLenM,       0, BBackHeight, [RIGHT,0,BOTTOM],R0, C6,  [1,RScale,1]);   
        }
        projectEnclose(){
          modBoarderWid(true,    0, RIGHT,      0, cutLenM, BBackHeight, [0,BACK,BOTTOM], R0, C6, [EScale,EScale,1]);
          modBoarderLen(true, BACK, LEFT, cutLenM,       0, BBackHeight, [RIGHT,0,BOTTOM],R0, C6,  [1,EScale,1]);  
        }
      }     
      
     //Thumb Section
      hull(){
        transEnclose(){
          modBoarderLenT(true, BACK, LEFT, cutLen,       0, BBackHeight, [LEFT,BACK,0], R0);
          modBoarderLenT(true, BACK, LEFT,cutLenM,       0, BBackHeight,  [LEFT,BACK,0], R1);  
        }  
        projectEnclose(){
          modBoarderLenT(true, BACK, LEFT, cutLen,       0, BBackHeight,    [LEFT,0,0], R0, [1,EScale,1]);
          modBoarderLenT(true, BACK, LEFT,cutLenM,       0, BBackHeight,     [LEFT,0,0], R1, [1,RScale,1]);  
        }   
      }
      hull(){
        transEnclose(){
          modBoarderLenT(true,BACK, LEFT, cutLenM,       0, BBackHeight,    [0,BACK,0], R1); 
        }
        projectEnclose(){
          modBoarderLenT(true,BACK, LEFT, cutLenM,       0, BBackHeight,       [0,0,0], R1, [1,RScale,1]); 
        }
      }
      hull(){
        transEnclose(){
          modBoarderLenT(true, BACK, LEFT,cutLenM,       0, BBackHeight, [RIGHT,BACK,0], R1); 
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight, [RIGHT,BACK,0], R1); 
        }
        projectEnclose(){  
          modBoarderLenT(true, BACK, LEFT,cutLenM,       0, BBackHeight,    [RIGHT,0,0], R1, [1,RScale,1]); 
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight,     [0,BACK,0], R1, [EScale,1,1]); 
        }
      }
      hull(){
        transEnclose(){
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight,   [BOTTOM,0,0], R1); 
        }
        projectEnclose(){  
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight,   [BOTTOM,0,0], R1, [EScale,1,1]); 
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight,   [0,BACK,TOP], R1, [EScale,1,1]); 
        }
      }
      hull(){
        transEnclose(){
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight,[BOTTOM,FRONT,0], R1); 
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM, BBackHeight, [BOTTOM,BACK,0], R2); 
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM, BBackHeight,[BOTTOM,FRONT,0], R2); 
       }
       projectEnclose(){
          modBoarderWidT(true,FRONT,RIGHT,      0, cutLenM, BBackHeight, [BOTTOM,FRONT,0], R1, [EScale,1,1]); 
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM, BBackHeight,  [BOTTOM,BACK,0], R2, [EScale,1,1]); 
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM, BBackHeight, [BOTTOM,FRONT,0], R2, [EScale,1,1]); 
       }  
      }  
      hull(){
        transEnclose(){
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM,  BBackHeight, [RIGHT,FRONT,0], R2); 
          modBoarderLenT(true,FRONT, LEFT,cutLenM,       0,  BBackHeight, [RIGHT,FRONT,0], R2); 
        }
        projectEnclose(){
    //      modBoarderWidT(true,FRONT,RIGHT, cutLenM,       0,  BBackHeight,[BOTTOM,FRONT,0], R2, [1,1,1]); 
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM, BBackHeight,[BOTTOM,FRONT,0], R2, [EScale,1,1]); 
        }
      } 
      hull(){
        transEnclose(){
          modBoarderLenT(true,FRONT, LEFT, cutLenM,       0,  BBackHeight,     [RIGHT,0,0], R2); 
          modBoarderWid(true, BACK,  LEFT,  cutLen,       0, BFrontHeight, [0,BACK,BOTTOM], R1, C1,[RScale,1,1]);
          modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight, [0,FRONT,BOTTOM], R0, C1,[RScale,1,1]);
        }
        projectEnclose(){
          modBoarderWidT(true, BACK,RIGHT,      0, cutLenM, BBackHeight,[BOTTOM,FRONT,0], R2, [EScale,1,1]); 
          modBoarderWid(true, BACK,  LEFT,   cutLen,       0, BFrontHeight, [0,BACK,BOTTOM], R1, C1,[EScale,1,1]);
          modBoarderWid(true, FRONT, LEFT, cutLenM,       0, BBackHeight, [0,FRONT,BOTTOM], R0, C1,[EScale,1,1]);
        }
      }
    }
    // basecut to remove artifact when height is set low 

  }
  //trackball
//    hullEnclusure(){
//    modBoarderWid(true, 0, LEFT, 0, BBackHeight, [0,BACK,BOTTOM], R0, C5);
//    modBoarderLen(true, BACK, 0, 0, BBackHeight, [LEFT,0,BOTTOM], R0, C5);  
//    modPlateWidT(Hulls = true, hullSides = [BOTTOM,0,BOTTOM], rows = R0);
//    modPlateWidT(Hulls = true, hullSides = [TOP,0,BOTTOM], rows = R1);
//  }          
  
  //MCU and Jacks
} 

//Trackball Module 
step = 5;

//--- shorthard transform to blob center

//Path function. 
  function oval_path(theta, phi, a, b, c, deform = 0) = [
   a*cos(theta)*cos(phi), //x
   c*sin(theta)*(1+deform*cos(theta)) , // 
   b*sin(phi),
  ];

  //oval path with linear angle offset 
  function oval_path2(theta, phi_init, a, b, c, d = 0, p = 1, deform = 0) = [
   a*cos(theta)*cos(phi_init), //x
   b*sin(theta)*(1+deform*cos(theta))*cos(phi_init + d * sin(theta*p)), // 
   c*sin(phi_init + d * sin(theta*p))
  ];

  //oval path with angle offset with hypersine 
  function oval_path3(theta, phi_init, a, b, c, d = 0, p = 1, deform = 0) = [
   a*cos(theta)*cos(phi_init), //x
   b*sin(theta)*(1+deform*cos(theta))*cos(phi_init + d * pow(sin(theta*p), 1)), // 
   c*sin(phi_init + d * pow(sin(theta*p), 3))
  ];

//shape functions 
function ellipse(a, b, d = 0) = [for (t = [0:step:360]) [a*cos(t), b*sin(t)*(1+d*cos(t))]]; //shape to 
  
// sweep generators 

module palm_track() {
  a = trackR;
  b = trackR; 
  c = trackR;
  //Ellipsoid([20*2,25*2,60],[30*2,25*2,60], center = true);
  function shape() = ellipse(3, 3);
  function shape2() = ellipse(4, 6);
  path_transforms =  [for (t=[0:step:180]) translation(oval_path3(t,20,a,c,b,30,1,0))*rotation([90,-20-20*sin(t),t])]; 
  path_transforms2 =  [for (t=[0:step:180]) translation(oval_path3(t,70,b,a,c,6,1,0))*rotation([90,-70+5*sin(t),t])];  
//  path_transforms3 =  [for (t=[0:step:360]) translation(oval_path3(t,-5,a,c,b,-15,1,0))*rotation([90,20+15*cos(t),t])];   
  path_transforms3 =  [for (t=[0:step:180]) translation(oval_path3(t,-20,a,c,b,-30,1,0))*rotation([90,20+20*sin(t),t])];   
  path_transforms4 =  [for (t=[0:step:360]) translation(oval_path3(t,-40,a,c,b,0,1,0))*rotation([90,40+sin(t),t])];  
   
 translate([0,0,-1]){ 
  rotate([-90,0,0])sweep(shape(), path_transforms);
  rotate([90,0,-90])sweep(shape(), path_transforms2); //tip
  rotate([90,0,90])sweep(shape(), path_transforms2);  //tip
  rotate([-90,0,0])sweep(shape(), path_transforms3); 
 }
 //support ring
 rotate([0,0,0])sweep(shape2(), path_transforms4); 
}


module PCB(){
  tol = .05;
  PL = 21/2+tol;
  PW = 18.6/2+tol;
  PT = 3;
  PCBT = 1.6;
  
  //Prism  
  translate([0,0,-PT])linear_extrude(PT)rounding(r=8)polygon([[PL,PW],[-PL,PW],[-PL,-PW],[PL,-PW]]);
  translate([PL-6,0,.5])cube([2,4,1],center= true);
  
  //PCB
  translate([0,0,-.8-PT])cube([28,21,PCBT],center= true);
  translate([24/2,0,-PT-PCBT-2])cylinder(d=2.44, 10);
  translate([-24/2,0,-PT-PCBT-2])cylinder(d=2.44, 10);
  
  //Apeture
  translate([0,0,0])cylinder(d1=5, d2= 12, 4);
}

PCBA = [45,0,0];
rbearing = .5;
module TrackBall(){
  difference(){
    union(){
     palm_track();
     rotate(PCBA)translate([0,0,-trackR-1])cube([30,22,8],center= true); // pcb housing
    }
      
//    sphere(d= trackR*2+.5); 
    //bearing holes

    //lower bearing
    for(i= [0:2])rotate([0,40,120*i-90])translate([trackR,0,0])sphere(r=rbearing); //upper bearing for tighter fit?
    for(i= [0:1])rotate([0,-10,180*i])translate([trackR,0,0])sphere(r=rbearing); //upper bearing for tighter fit?
    rotate(PCBA)translate([0,0,-42/2])PCB();
  }
}

module mockPCB(thickness,offsets ){
  for(cols = [CStart:C4]){
    color("blue")PlaceColumnOrigin(cols)translate([25,offsets,0])rotate([90,0,0])cube([28,15,thickness],center = true);
  }
  color("blue")PlaceColumnOrigin(C5)translate([18,offsets+1,7.5])rotate([90,0,0])rotate([-10,0,0])cube([35,25,thickness],center = true);
}
//##################   Section E:: Key Switches and Caps   ##################  
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

//##################   Section F:: Main Calls    ##################
//rotate([0,0,360*$t]){
  difference(){
  union(){
    rotate(tenting)translate([0,0,plateHeight])BuildTopPlate(keyhole = true, trackball = false, channel = false, platethickness =-1);
//    BuildEnclosure(trackball = true, platethickness = -1);
//    rotate(tenting)translate([0,0,plateHeight])mockPCB(1, 3);    
    rotate(tenting)translate([0,0,plateHeight])translate(trackOrigin)rotate(trackTilt)TrackBall();
  }
//  translate([0,0,-10])cube([200,100,20], center = true);
  rotate(tenting)translate([0,0,plateHeight])translate(trackOrigin)color("royalblue")sphere(d=trackR*2+.5,$fn= 64);
}

//mock ups for visualization 
  //caps
  rotate(tenting)translate([0,0,plateHeight]){
//    BuildSet2();
    PlaceOnThumb(0)rotate([0,0,-0])Switch(colors = "Steelblue",clipLength = cutLen);
    PlaceOnThumb(1)rotate([0,0,-0])Switch(colors = "Steelblue",clipLength = cutLen);
    PlaceOnThumb(2)rotate([0,0,-0])Switch(colors = "Steelblue",clipLength = cutLen);
    PlaceOnThumb(3)rotate([0,0,-0])Switch(colors = "Steelblue",clipLength = cutLen);
  }
  //TrackBall
  rotate(tenting)translate([0,0,plateHeight])translate(trackOrigin)color("royalblue")sphere(d=trackR*2,$fn= 64);

  
  
  
  
  
  
  
  
  
