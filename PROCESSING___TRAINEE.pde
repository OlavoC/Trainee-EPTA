import processing.serial.*;
Serial mySerial;
PrintWriter output;

int numValues = 9;
int paraquedas = 150;

float[] values = new float[numValues];
int[] min = new int[numValues];
int[] max = new int[numValues];
color[] valColor = new color[numValues];
float partH;
int xPos = 0;
boolean clearScreen = true; 


void setup() {
  size(800, 600);
  partH = height / 10;
  

  printArray(Serial.list());
  String portName = Serial.list()[0];
  mySerial = new Serial(this, portName, 9600);
  output = createWriter( "data.txt" );
  mySerial.bufferUntil(',');

  textSize(10);

  background(0);
  noStroke();
 
  values[0] = 0;
  min[0] = 0;  
  max[0] = 1023; 
  valColor[0] = color(255, 0, 0);   

  values[1] = 0; 
  min[1] = 0;
  max[1] = 1023;  
  valColor[1] = color(0, 255, 0); 

  values[2] = 0;
  min[2] = 0;
  max[2] = 1023;    
  valColor[2] = color(0, 0, 255); 
  
  values[3] = 0;
  min[3] = 0;
  max[3] = 1023; 
  valColor[3] = color(100, 0, 255); 
  
    
  values[4] = 0;
  min[4] = 0;
  max[4] = 1023; 
  valColor[4] = color(255, 0, 100); 
  
    
  values[5] = 0;
  min[5] = 0;
  max[5] = 1023; 
  valColor[5] = color(255, 100, 255); 
  
    
  values[6] = 0;
  min[6] = 0;
  max[6] = 1023; 
  valColor[6] = color(25, 0, 55); 
  
    
  values[7] = 0;
  min[7] = 0;
  max[7] = 1023; 
  valColor[7] = color(55, 0, 25); 
  
    
  values[8] = 0;
  min[8] = 0;
  max[8] = 1023; 
  valColor[8] = color(140, 120, 255); 
 
}


void draw() 
{
  
 
  fill(150,255,60);
  rect(300, 550,200 ,40);
  fill(0, 0, 0);
  textSize(10);
  textAlign(CENTER);
  text("Paraquedas", 400, 570);
  
  
  if (mousePressed && mouseX > 300 && mouseX < 500 && mouseY > 550 && mouseY < 590)
  {
    if (paraquedas == 255)
    {
      mySerial.write("d");

    }
    else if (paraquedas == 150)
    {
      mySerial.write("l");
      fill(255,0,0);
      text("PARAQUEDAS ATIVADO", 600, 570);
    }
    fill(0,0,255);
    rect(300, 550,200 ,40);
  }
  
  /*
  if(mySerial.available() >= 0)
  {
     String valor = mySerial.readString();
     if(valor != null)
     {
      output.println(valor);
     }
  }
  */
  
  
  if (clearScreen) 
  {
    background(0); 
    clearScreen = false; // reset flag
  } 

  for (int i=0; i<numValues; i++) 
  {
    float mapeado = map(values[i], min[i], max[i], 0, partH);

    // draw lines:
    stroke(valColor[i]);
    line(xPos, partH*(i+1), xPos, partH*(i+1) - mapeado);

    // draw dividing line:
    stroke(255);
    line(0, partH*(i+1), width, partH*(i+1));

    // display values on screen:
    fill(50);
    noStroke();
    rect(0, partH*i+1, 70, 12);
    fill(255);
    text(round(values[i]), 2, partH*i+10);
    fill(125);
    text(max[i], 40, partH*i+10);
  
    print(values[i] + ",");
  }
  
  print("\n");
  xPos++; 
  
  if (xPos > width) 
  {
    xPos = 0;
    clearScreen = true;
  }
         
   
}


void serialEvent(Serial mySerial) 
{ 
   
  try 
  {
    String inString = mySerial.readStringUntil('\n');
    
    if (inString != null)
    {
      inString = trim(inString);
      values = float(splitTokens(inString, ",")); 
    }
  }
  
  catch(RuntimeException e)
  {
    e.printStackTrace();
  }
}

void mouseClicked() 
{
  if (mouseX > 300 && mouseX > 500 && mouseY > 550 && mouseY < 590)
  {
     if(paraquedas == 150)
     {
       paraquedas = 255;
     }
     if(paraquedas == 255)
     {
       paraquedas = 155;
     }  
    fill(0,255,60);
    rect(300, 550,200 ,40);
     
  }
}



void keyPressed() 
{
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
    exit();  // Stops the program
}
