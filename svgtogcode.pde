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

//import controlP5.*;
//ControlP5 cp5;

gcodeWriter gh = new gcodeWriter();
String inputFilePath;
String outputFilePath;

void setup()
{
  size(displayWidth, displayHeight);
  noStroke();

  selectInput("Select a file to process:", "inputFileSelected");
}

void draw()
{
  if (inputFilePath != null) 
  {
    PShape file = loadShape(inputFilePath);

    svgHandler svgh;
    svgh = new svgHandler(file);
    shape(file);
    println(gh.gcode);

    selectOutput("Select a file to write to:", "outputFileSelected");

    noLoop();
  }
}

void inputFileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    inputFilePath = selection.getAbsolutePath();
  }
}

void outputFileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    outputFilePath = selection.getAbsolutePath();
    String[] valueArray = split(gh.gcode, '\n');
    saveStrings(outputFilePath + ".gcode", valueArray);
  }
}

