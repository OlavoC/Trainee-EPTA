import processing.serial.*;
Serial mySerial;
PrintWriter output;


//Definindo variáveis
int numValues = 9; //Quantidade de dados
int paraquedas = 150; //Valor enviado pelo botão
float[] values = new float[numValues]; //vetor de dados (values[0] = alt, values[1] = pres, ... , values[8] = aGyZ)
int[] min = new int[numValues]; //minímo local de cada dado
int[] max = new int[numValues]; //máximo local de cada dado
color[] valColor = new color[numValues]; // cor de cada gráfico
float h; 
int xPos = 0; //posição inicial
boolean clearScreen = true; //booleana para indiar se a tela precisa ser limpa


void setup() {
  //Criando janela
  size(800, 600);
  h = height / 10; //Critério utilizado para definir a artura de cada região
  
  //Definindo serial
  printArray(Serial.list());
  String portName = Serial.list()[0];
  mySerial = new Serial(this, portName, 9600);
  
  //Criando arquivo txt
  output = createWriter( "data.txt" );
  
  mySerial.bufferUntil(',');

  //Tamanho dos textos, cor do plano de fundo e 
  textSize(10);
  background(0);
  noStroke();
 
 //Definindo os intervalos máximos e mínimos de cada sensor e as cores de cada gráfico
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
  valColor[3] = color(255, 165, 0); 
  
    
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
  valColor[6] = color(255, 255, 255); 
  
    
  values[7] = 0;
  min[7] = 0;
  max[7] = 1023; 
  valColor[7] = color(255, 255, 0); 
  
    
  values[8] = 0;
  min[8] = 0;
  max[8] = 1023; 
  valColor[8] = color(153, 51, 153); 
 
}

//Equivalente ao void loop
void draw() 
{
  
 //Desenho do botão
  fill(150,255,60);
  rect(300, 550,200 ,40);
  fill(0, 0, 0);
  textSize(10);
  textAlign(CENTER);
  text("Paraquedas", 400, 570);
  
  
  //Definindo o que seré printados no serial do arduino caso o botão seja pressionado
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
    //Mudando cor do botão ao ser clicado
    fill(0,0,255);
    rect(300, 550,200 ,40);
  }
  
  //Salvando dados em arquivo .txt local
  if(mySerial.available() >= 0)
  {
     String valor = mySerial.readStringUntil('\n');
     if(valor != null)
     {
      output.println(valor);
     }
  }
  
  //"Limpa" a tela quando os gráficos atingem o final da tela
  if (clearScreen) 
  {
    background(0); 
    clearScreen = false; 
  } 


  for (int i=0; i<numValues; i++) 
  {
    //Mapeando onde o dado será printado
    float mapeado = map(values[i], min[i], max[i], 0, h);

    //Desenha o gráfico
    stroke(valColor[i]);
    line(xPos, h*(i+1), xPos, h*(i+1) - mapeado);

    //Desenha linha de divisão
    stroke(255);
    line(0, h*(i+1), width, h*(i+1));

    //Plota valores em tempo real
    fill(50);
    noStroke();
    rect(0, h*i+1, 70, 12);
    fill(255);
    text(round(values[i]), 2, h*i+10);
    fill(125);
    text(max[i], 40, h*i+10);
  
    print(values[i] + ",");
  }
  
  print("\n");
  xPos++; 
  
  //Checa se os gráficos chegaram ao final da tela
  if (xPos > width) 
  {
    xPos = 0;
    clearScreen = true;
  }
         
   
}

//Função responsável por ler dados do serial
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

//Função para identificar clique do mouse e alterar o valor da variável para que a mensagem seja enviada
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


//Comando para finalizar o programa e salvar dados no cartão SD
void keyPressed() 
{
    output.flush(); 
    output.close(); 
    exit();  
}
