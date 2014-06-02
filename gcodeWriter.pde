/**
 *  svgtogcode 
 *  Copyright 2014 Sephen de Vos
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 3 as published by
 *  the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  See: <http://www.gnu.org/licenses/>
 *  
 */
 
class gcodeWriter
{
  String gcode = "";

  public gcodeWriter()
  {
    // Set mm
    this.newLine("G21");
    // Set absolute 
    this.newLine("G90");

    // Home axis
    this.newLine("G28");
    this.addToLine("X0 Y0 Z1");
  }

  void rect(
  float firstPointX, float firstPointY, 
  float secondPointX, float secondPointY, 
  float thirdPointX, float thirdPointY, 
  float fourthPointX, float fourthPointY)
  {
    this.newLine("G0");
    this.addToLine("X"+firstPointX + " Y" + firstPointY);
    this.lowerPen();
    this.newLine("G1");
    this.addToLine("X"+secondPointX + " Y" + secondPointY);
    this.newLine("G1");
    this.addToLine("X"+thirdPointX + " Y" + thirdPointY);
    this.newLine("G1");
    this.addToLine("X"+fourthPointX + " Y" + fourthPointY);
    this.newLine("G1");
    this.addToLine("X"+firstPointX + " Y" + firstPointY);
    this.liftPen();
  }

  void newLine(String code)
  {
    gcode += "\r\n";
    gcode += code + " ";
  }

  void addToLine(String string)
  {
    gcode += string + " ";
  }

  void liftPen()
  {
    gh.newLine("G0");
    gh.addToLine("Z1");
  }
  void lowerPen()
  {
    gh.newLine("G0");
    gh.addToLine("Z0");
  }
}

