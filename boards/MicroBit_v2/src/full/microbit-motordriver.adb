------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2018, AdaCore                        --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------
with MicroBit.I2C;
package body MicroBit.MotorDriver is


   MD  : DFR0548.MotorDriver (MicroBit.I2C.ControllerExt);

   procedure Initialize is
   begin
      if not MicroBit.I2C.InitializedExt then
         MicroBit.I2C.InitializeExt;
      end if;

      MD.Initialize;
      MD.Set_Frequency_Hz (50); --50 Hz
   end Initialize;

   procedure Drive (Direction : Directions;
                    Speed : Speeds := (4095,4095,4095,4095)) is
      --Note: See implementation of wheel to be (Forward, Backward)
      --!! They can never be a non zero value at the same time !! eg. rf => (4000,2000) is illegal
      --rf = right front wheel, rb = right back wheel, etc.
      --for example direction see:
   begin
      case Direction is
         when Forward =>
            Drive_Wheels(rf => (Speed.rf, 0),
                         rb => (Speed.rb, 0),
                         lf => (Speed.lf, 0),
                         lb => (Speed.lb, 0));
         when Left =>
            Drive_Wheels(rf => (Speed.rf ,0),
                         rb => (0, Speed.rb),
                         lf => (0, Speed.lf),
                         lb => (Speed.lb, 0));
         when Right =>
            Drive_Wheels(rf => (0, Speed.rf),
                         rb => (Speed.rb, 0),
                         lf => (Speed.lf ,0),
                         lb => (0, Speed.lb));
         when Forward_Left => --forward left diagonal
            Drive_Wheels(rf => (Speed.rf, 0),
                         rb => (0, 0),
                         lf => (0, 0),
                         lb => (Speed.lb, 0));
         when Backward_Left => --backward left diagonal
            Drive_Wheels(rf => (0, Speed.rf),
                         rb => (0, 0),
                         lf => (0, 0),
                         lb => (0, Speed.lb));
         when Turning_Left => --Same as Forward, wheelspeed left < wheelspeed right results in curved left
            Drive_Wheels(rf => (Speed.rf, 0),
                         rb => (Speed.rb, 0),
                         lf => (Speed.lf, 0),
                         lb => (Speed.lb ,0));
                     when Turning_Right => --Same as Forward, wheelspeed left < wheelspeed right results in curved left
            Drive_Wheels(rf => (Speed.rf, 0),
                         rb => (Speed.rb, 0),
                         lf => (Speed.lf, 0),
                         lb => (Speed.lb ,0));
         when Lateral_Left =>
            Drive_Wheels(rf => (Speed.rf,0),
                         rb => (0, 0),
                         lf => (0,Speed.lf),
                         lb => (0, 0));
         when Rotating_Left => --same as left?
            Drive_Wheels(rf => (Speed.rf,0),
                         rb => (speed.rb,0),
                         lf => (0,Speed.lf),
                         lb => (0, speed.lb));
         when Stop =>
            Drive_Wheels(rf => (0, 0),
                         rb => (0, 0),
                         lf => (0, 0),
                         lb => (0, 0));
         when Forward_Right =>
            Drive_Wheels(rf => (0, 0),
                         rb => (0, speed.rb),
                         lf => (speed.lf, 0),
                         lb => (0, 0));
         when Backward_Right=>
            Drive_Wheels(rf => (0, 0),
                         rb => (0, speed.lf),
                         lf => (0, speed.lf),
                         lb => (0, 0));
         when Backward_Turning => --Same as Backward, wheelspeed left < wheelspeed right results in front of the car turning right
            Drive_Wheels(rf => (0, speed.rf),
                         rb => (0, speed.rb),
                         lf => (0, speed.lf),
                         lb => (0, speed.lb));
         when Lateral_Right =>
            Drive_Wheels(rf => (0, speed.rf),
                         rb => (0, 0),
                         lf => (speed.lf,0),
                         lb => (0, 0));
         when Rotating_Right => --same as Right? Setup because there was a Rotating_Left
            Drive_Wheels(rf => (0, Speed.rf),
                         rb => (0, speed.rb),
                         lf => (Speed.lf ,0),
                         lb => (speed.lb, 0));
         when Backward =>
            Drive_Wheels(rf => (0, speed.rf),
                         rb => (0, speed.rb),
                         lf => (0, speed.lf),
                         lb => (0, speed.lb));
      end case;
   end Drive;

   procedure Drive_Wheels(rf : Wheel;
                         rb : Wheel;
                         lf : Wheel;
                         lb : Wheel ) is
   begin
         MD.Set_PWM_Wheels (rf, rb, lf, lb);
   end Drive_Wheels;

   procedure Servo (ServoPin : ServoPins ;
                    Angle : Degrees)
   is
   begin
         MD.Set_Servo(ServoPin, Angle);
   end Servo;

begin
   Initialize;
end MicroBit.MotorDriver;
