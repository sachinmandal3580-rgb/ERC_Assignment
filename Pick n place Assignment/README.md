
### Resources:-
 https://youtu.be/pDiwAA1cnb0?si=fMVpgHlqDLwUy5Za , https://youtu.be/2KWamTAR3t0?si=bennIzi5sG0VfsyV , 
 https://www.mathworks.com/help/sm/getting-started-with-simscape-multibody.html


## Here's the explanation for connections 

# Belt Out/In Connections

## Word Frame
First of all the __World__ and __Config__ --> rigids trandforms,i.e., Transform Belt Out/In(because the simulation needs to know their position relative to the world frame, like belt In at -90deg and Belt Out at 180deg from +Z axis and __config__ block acts as a Simscape Configuration block that sets solver-level settings: gravity vector direction/magnitude, mechanical stiffness tolerances, etc.)

## Transforms  & Force 
Then Transform Belt Out/In --> Box To belt Out/In Force(Calculate the Contact Force b/w Belt & Box using the 3-D transforms from Rigid transforms) --> goto with tags Out/In (routes the signal from output contact forces to Scope for Normal Force Curve) 

## Controller 
Also PlaB of Box to Belt In/Out --> ctr of Belt In/Out(to make controller aware of where they are using Physical Frame port to compute the contact forces)

## Commands
Commands(Belt Out/In) --> Bus_On(to control the speed/On-Off status of the conveyer belt) -->Box to Belt Out/In Force(sends these signals for friction/contact force calculations) and also Commands --> Belt Out/In(to give 
speed to belts)

## Gripper 
Commands(xF, qF, zP, qQ) --> Gripper(z, q, z, q)(signals every component of gripper to pick & place the box) --> Damper Gripper Force(Fa, E, Fb)(to perfectly lift the box with enough contact/friction forces and gradual grip force build up not instantly)

# Box Connections

## World Frame
World frame --> init Box 6-DOF Joint --> Box(F port)( receives Joint frame including the initial position and orientation)

## Gripping the Box
Damper Gripper Force(Bfa, Bfb) --> Box(Fa, Fb)(to grip the box with damped force to smoothly and slowly hold it)

# Scope Curve
# Goto-From
***Goto*** --> takes the output signal from one node to other without wires and ***from*** --> receives the signals & passes to __Normal force Visualizer Scope__

#### Box to Belt Out Force(out) --> goto(tag- [Out] ) --> from(tag - [Out] ) --> Scope Shows the Normal Force variation b/w the belt out & box

#### Similarly, Box to Belt In Force(out) --> goto(tag- [In] ) --> from(tag - [In] ) --> Scope Shows the Normal Force variation b/w the belt In & box

### THANK YOU


