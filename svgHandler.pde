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
 
class svgHandler
{
  public svgHandler(PShape File)
  {
    for (int i=0;i<File.getChildCount();i++)
    {
      this.recursiveChildLoop(File.getChild(i));
      this.childHandler(File.getChild(i));
    }
  }

  void recursiveChildLoop(PShape child)
  {
    for (int i=0;i<child.getChildCount();i++)
    {
      this.childHandler(child.getChild(i));
      this.recursiveChildLoop(child.getChild(i));
    }
    return;
  }

  void childHandler(PShape child)
  {
    if (child.isVisible())
    {
      if (this.getFamilyName(child.getFamily()) == "GROUP")
      {
        println(child.getFamily() + " - GROUP");
      } else if (this.getFamilyName(child.getFamily()) == "PRIMITIVE")
      {
        println(child.getFamily() + " - PRIMITIVE");
        if (this.getKindName(child.getKind()) == "LINE")
        {
          this.lineHandler(child);
        } else if (this.getKindName(child.getKind()) == "RECT")
        {
          this.rectHandler(child);
        } else if (this.getKindName(child.getKind()) == "ELLIPSE")
        {
          this.ellipseHandler(child);
        } else
        {
          this.getKindName(child.getKind());
        }
      } else if (this.getFamilyName(child.getFamily()) == "PATH")
      {
        println(child.getFamily() + " - PATH");
        if (child.getVertexCodeCount() > 0)
        {
          this.pathHandler(child);
        } else
        {
          this.polyPathHandler(child);
        }
      }
    }
  }

  void lineHandler(PShape child)
  {
    // Get the params
    float x = child.getParams()[0];
    float y = child.getParams()[1];
    float endx = child.getParams()[2];
    float endy = child.getParams()[3];

    // GCode travel to first location
    gh.newLine("G0");
    gh.addToLine("X"+ this.round(x, 3) + " Y" + this.round(y, 3));
    gh.lowerPen();
    // First point is same as travel-to-point
    gh.newLine("G1");
    gh.addToLine("X"+ this.round(x, 3) + " Y" + this.round(y, 3));
    gh.newLine("G1");
    gh.addToLine("X"+ this.round(endx, 3) + " Y" + this.round(endy, 3));
    gh.liftPen();

    // draw rect points on screen
    strokeWeight(6);
    stroke(255, 0, 255); // Magenta
    point(x, y);
    point(endx, endy);
  }

  void ellipseHandler(PShape child)
  {
    // Get the params
    float x = child.getParams()[0];
    float y = child.getParams()[1];
    float width = child.getParams()[2];
    float height = child.getParams()[3];

    for (float i=0; i<2*PI; i+=precision)
    {
      float nx = (width/2)*cos(i) + x+(width/2);
      float ny = (height/2)*sin(i) + y+(height/2);

      if (i == 0)
      {
        // GCode travel to first location
        gh.newLine("G0");
        gh.addToLine("X"+ this.round(nx, 3) + " Y" + this.round(ny, 3));
        gh.lowerPen();
        // First point is same as travel-to-point
        gh.newLine("G1");
        gh.addToLine("X"+ this.round(nx, 3) + " Y" + this.round(ny, 3));
      } else 
      {
        gh.newLine("G1");
        gh.addToLine("X"+ this.round(nx, 3) + " Y" + this.round(ny, 3));
      }

      // draw rect points on screen
      strokeWeight(6);
      stroke(255, 0, 255); // Magenta
      point(nx, ny);
    }

    // End of Shape lift pen
    gh.liftPen();
  }

  void pathHandler(PShape child)
  {
    // GCode travel to first location
    gh.newLine("G0");
    gh.addToLine("X"+child.getVertex(0).x + " Y" + child.getVertex(0).y);
    gh.lowerPen();

    // set iteration for the vertices
    int i = 0;
    for (int j=0;j<child.getVertexCodeCount();j++)  // For normal Path we use getVertexCodeCount
    {
      if (this.getVertexName(child.getVertexCode(j)) == "VERTEX")
      {
        this.vertexHandler(child.getVertex(i));
        i++;
      } else if (this.getVertexName(child.getVertexCode(j)) == "BEZIER_VERTEX")
      {
        // if its a bezier get the previous point because the last point of the previous is this line's start
        this.bezierVertexHandler(child.getVertex(i-1), child.getVertex(i), child.getVertex(i+1), child.getVertex(i+2));
        i = i+3;
      }
    }
    // End of Shape lift pen
    gh.liftPen();
  }

  void polyPathHandler(PShape child)
  {
    // GCode travel to first location
    gh.newLine("G0");
    gh.addToLine("X"+child.getVertex(0).x + " Y" + child.getVertex(0).y);
    gh.lowerPen();

    // set iteration for the vertices
    int i = 0;
    for (int j=0;j<child.getVertexCount();j++) // For POLY we use getVertexCount
    {
      this.vertexHandler(child.getVertex(j));
    }
    // End of Shape lift pen
    gh.liftPen();
  }

  void rectHandler(PShape child)
  {
    // Get the params
    float x = child.getParams()[0];
    float y = child.getParams()[1];
    float width = child.getParams()[2];
    float height = child.getParams()[3];

    // Get the points
    float firstPointX = x;
    float firstPointY = y;
    float secondPointX = x + width;
    float secondPointY = y;
    float thirdPointX = x + width;
    float thirdPointY = y + height;
    float fourthPointX = x;
    float fourthPointY = y + height;

    // create gcode rect
    gh.rect(this.round(firstPointX, 3), this.round(firstPointY, 3), this.round(secondPointX, 3), this.round(secondPointY, 3), this.round(thirdPointX, 3), this.round(thirdPointY, 3), this.round(fourthPointX, 3), this.round(fourthPointY, 3));

    // draw rect points on screen
    strokeWeight(6);
    stroke(255, 0, 255); // Magenta
    point(firstPointX, firstPointY);
    point(secondPointX, secondPointY);
    point(thirdPointX, thirdPointY);
    point(fourthPointX, fourthPointY);
  }

  void vertexHandler(PVector vertex)
  {
    // get the pointe
    float x = vertex.x;
    float y = vertex.y;

    //draw gcode coordinate
    gh.newLine("G1");
    gh.addToLine("X"+this.round(x, 3)+ " Y" + this.round(y, 3));

    // draw the point on screen
    strokeWeight(6);
    stroke(255, 0, 255); // Magenta
    point(x, y);
  }

  void bezierVertexHandler(PVector p0, PVector p1, PVector p2, PVector p3)
  {
    for (float i=0; i<1; i+=precision)
    {
      float x = CalculateBezierPoint(i, p0.x, p1.x, p2.x, p3.x);
      float y = CalculateBezierPoint(i, p0.y, p1.y, p2.y, p3.y);

      //draw gcode coordinate
      gh.newLine("G1");
      gh.addToLine("X"+this.round(x, 3) + " Y" + this.round(y, 3));

      // draw the point on screen
      strokeWeight(6);
      stroke(255, 0, 255); // Magenta
      point(x, y);
    }
  }

  Float CalculateBezierPoint(float t, float p0, float p1, float p2, float p3)
  {
    float u = 1 - t; 
    float tt = t*t;
    float uu = u*u;
    float uuu = uu * u;
    float ttt = tt * t;

    float p = uuu * p0; //first term
    p += 3 * uu * t * p1; //second term
    p += 3 * u * tt * p2; //third term
    p += ttt * p3; //fourth term

    return p;
  }

  String getFamilyName(int family) 
  {
    switch (family) 
    {
    case GROUP:
      return "GROUP";
    case PShape.PRIMITIVE:
      return "PRIMITIVE";
    case PShape.GEOMETRY:
      return "GEOMETRY";
    case PShape.PATH:
      return "PATH";
    }
    return "unknown family: " + family;
  }

  String getKindName(int kind) 
  {
    switch (kind) 
    {
    case LINE:
      return "LINE";
    case LINES:
      return "LINES";
    case PShape.ELLIPSE:
      return "ELLIPSE";
    case PShape.RECT:
      return "RECT";
    case PShape.POLYGON:
      return "POLYGON";
    case PShape.TRIANGLE:
      return "TRIANGLE";
    case 0:
      return "PATH";
    }
    return "unknown kind: " + kind;
  }

  String getVertexName(int vertex)
  {
    switch (vertex) 
    {
    case 0:
      return "VERTEX";
    case 1:
      return "BEZIER_VERTEX";
    case 2:
      return "CURVE_VERTEX";
    case 3:
      return "BREAK";
    }
    return "unknown: " + vertex;
  }

  float round(float val, int dp)
  {
    return int(val*pow(10, dp))/pow(10, dp);
  }
}

