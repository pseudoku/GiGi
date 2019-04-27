// adjust as needed 
$fn = 360;  //rip render time takes about 30min at 70 for hatch design 
dimpleR = 40; //radius of dimple

//##### Generaton Calls ######

translate([20,0,0])KailhCapR2(false, true);
translate([-20,0,0])KailhCapR1();
translate([0, 8.5,0])rotate([15,0,0])KailhCapR();
translate([0,-8.5,0])rotate([15,0,180])KailhCapR();
//  translate([0,-8,0])cube([20,10,10],center =true);


//#############################

//#### Modules ################
module KailhCapR2(hatch = false, home = false){
  difference(){
    hull(){
     translate([0,0,1])cube([17.3,16.4,2],center = true);
     translate([0,.75,1+2.5])cube([14.5,12,1.5],center = true);
    }
  //cuts
    translate([0,0,.75])cube([17.5-2.5,16.8-2.5,2.1],center = true); //
    translate([0,1.25,dimpleR + 2.5])sphere(r=dimpleR);
      
    if(hatch == true){
      for(i= [-4:4]){ 
      translate([0,1.25,dimpleR +.5+2.5])rotate([-90+i*3,0,45])rotate_extrude(angle = 180)translate([dimpleR +.1,0])circle(.5);
      translate([0,1.25,dimpleR +.5+2.5])rotate([-90+i*3,0,-45])rotate_extrude(angle = 180)translate([dimpleR +.1,0])circle(.5);
      } 
    }
  }
  
  //legs
  translate([5.7/2,0,-3.4/2+2])difference(){
    cube([1.25,3, 3.4], center= true);
    translate([3.9,0,0])cylinder(d=7,3.4,center = true);
    translate([-3.9,0,0])cylinder(d=7,3.4,center = true);
  }
  translate([-5.7/2,0,-3.4/2+2])difference(){
    cube([1.25,3, 3.4], center= true);
    translate([3.9,0,0])cylinder(d=7,3.4,center = true);
    translate([-3.9,0,0])cylinder(d=7,3.4,center = true);
  }
  
  //homing bump
  if(home == true){
    translate([0,1,0])rotate([0,0,0])translate([0,1.25,2.1])sphere(r = .75);
    translate([0,1,0])rotate([0,0,120])translate([0,1.25,2.1])sphere(r = .75);
    translate([0,1,0])rotate([0,0,240])translate([0,1.25,2.1])sphere(r = .75);
  }
}

module KailhCapR1(hatch = false){
  shift = -10 ;
  difference(){
    union(){
      hull(){
        translate([0,0,1])cube([17.3,16.4,1.5],center = true);
        translate([0,.75,1+2])cube([14.5,12,1.5],center = true);
      }
    }
  //cuts
  translate([0,0,.75])cube([17.5-2.5,16.8-2.5,2.1],center = true);
  translate([0,shift, dimpleR + 2])sphere(r=dimpleR );

  if(hatch == true){
    for(i= [-4:5]){ 
      translate([0, shift,dimpleR +.5+2.])rotate([-90+i*3,0,45])rotate_extrude(angle = 180)translate([dimpleR +.1,0])circle(.5);
      translate([0, shift,dimpleR +.5+2.])rotate([-90+i*3,0,-45])rotate_extrude(angle = 180)translate([dimpleR +.1,0])circle(.5);
    } 
   for(i= [-2:4]){ 
     fact = 1.45;
    translate([0+i*fact,shift+11.5+i*fact,4])rotate([90,0,45])cylinder(r= .5, 20, center= true);
    translate([0-i*fact,shift+11.5+i*fact,4])rotate([90,0,-45])cylinder(r= .5, 20, center= true);
   }
  }
  //uncommment for cross section for wall thickness check
//    translate([0,16.8/4,1])cube([17.5,16.8/2,5],center = true); 
  }
  
  //Legs
    translate([5.7/2,0,-3.4/2+2])difference(){
      cube([1.3,3, 3.4], center= true);
      translate([3.9,0,0])cylinder(d=7,3.4,center = true);
      translate([-3.9,0,0])cylinder(d=7,3.4,center = true);
    }
    translate([-5.7/2,0,-3.4/2+2])difference(){
      cube([1.3,3, 3.4], center= true);
      translate([3.9,0,0])cylinder(d=7,3.4,center = true);
      translate([-3.9,0,0])cylinder(d=7,3.4,center = true);
    }
}

module KailhCapR(hatch = false, home = false){
  shift = -5 ;
  difference(){
    union(){
      rotate([0,0,180])hull(){
        translate([0,0,1])cube([17.3,16.4,2],center = true);
        translate([0,.75,1+2.5])cube([14.5,12,1.5],center = true);
      }
    }
//cuts
  translate([0,0,.75])cube([17.5-2.5,16.8-2.5,2.1],center = true); //
  
  translate([0,shift, dimpleR + 2.5])sphere(r=dimpleR );

  if(hatch == true){
    for(i= [-4:5]){ 
      translate([0, shift,dimpleR +.5+2.5])rotate([-90+i*3,0,45])rotate_extrude(angle = 180)translate([dimpleR +.1,0])circle(.5);
      translate([0, shift,dimpleR +.5+2.5])rotate([-90+i*3,0,-45])rotate_extrude(angle = 180)translate([dimpleR +.1,0])circle(.5);
    } 
   for(i= [-4:2]){ 
     fact = 1.45;
    translate([0+i*fact,shift+11.5+i*fact,3.5])rotate([90,0,45])cylinder(r= .5, 20, center= true);
    translate([0-i*fact,shift+11.5+i*fact,3.5])rotate([90,0,-45])cylinder(r= .5, 20, center= true);
   }
  }
//    translate([0,16.8/4,1])cube([17.5,16.8/2,5],center = true); //cross section 
  }
  
    translate([5.7/2,0,-3.4/2+2])difference(){
      cube([1.3,3, 3.4], center= true);
      translate([3.9,0,0])cylinder(d=7,3.4,center = true);
      translate([-3.9,0,0])cylinder(d=7,3.4,center = true);
    }
    translate([-5.7/2,0,-3.4/2+2])difference(){
      cube([1.3,3, 3.4], center= true);
      translate([3.9,0,0])cylinder(d=7,3.4,center = true);
      translate([-3.9,0,0])cylinder(d=7,3.4,center = true);
    }
  if(home == true){
    translate([0,1,0])rotate([0,0,0])translate([0,1.25,2.1])sphere(r = .75);
    translate([0,1,0])rotate([0,0,120])translate([0,1.25,2.1])sphere(r = .75);
    translate([0,1,0])rotate([0,0,240])translate([0,1.25,2.1])sphere(r = .75);
  }
}