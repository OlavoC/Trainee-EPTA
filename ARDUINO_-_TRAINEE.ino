#include <SPI.h> 
#include <nRF24L01.h> //Biblioteca
#include <RF24.h> 
#include<Wire.h>
#include <Servo.h>
#include <SFE_BMP180.h> //Biblioteca do barômetro
#include <SdFat.h> //Biblioteca do cartão SD

SdFat sdCard;
SdFile meuArquivo;

const int chipSelect = CS;

SFE_BMP180 bmp180;
#define  SERVO 6 // Porta 6 PWM
 
Servo paraquedas;  
float Po = //preencher com pressão do local de vôo;

//definindo mpu
const int MPU = 0x68;  
float AcX,AcY,AcZ,Tmp,GyX,GyY,GyZ; // Variáveis para os dados do acelerômetro e do giroscópio


RF24 radio(CE, CSN); //Transceptor
const byte address[6] = "00002"; //Endereço de cabeçalho para comunicação

RF24 radio(CE, CSN); //Receptor
const byte address2[6] = "00003"; 

void setup()
{
  Serial.begin(9600);
  radio.begin(); 
  
  //Definindo transceptor
  radio.openWritingPipe(address); 
  radio.setPALevel(RF24_PA_HIGH);
  radio.stopListening(); 
  
  //Definindo receptor
  radio.openReadingPipe(0, address2);
  radio.startListening();
   
  //Incializa MPU
  Wire.write(0); 
  Wire.endTransmission(true);

  //Definindo posição inicial do servo
  servo.attach(SERVO);
  servo.write(0); 

  //Iniciando cartão sd
  if(!sdCard.begin(chipSelect,SPI_HALF_SPEED))sdCard.initErrorHalt();
  if (!meuArquivo.open("data.txt", O_RDWR | O_CREAT | O_AT_END))
  {
    sdCard.errorHalt("Erro na abertura do arquivo data.TXT!");
  }

  //Inicinado BMP 
 bool success = bmp180.begin();

  if (success) {
    Serial.println("BMP180 init success");
  }
  
}
 
void loop()
{  
  //Iniciando MPU
  Wire.beginTransmission(MPU);
  Wire.write(0x3B); 
  Wire.endTransmission(false);
  Wire.requestFrom(MPU,14,true);  
   
  //Dados do acelerômetro
  AcX=Wire.read()<<8|Wire.read();  // Aceleração em X
  AcY=Wire.read()<<8|Wire.read();  // Aceleração em Y
  AcZ=Wire.read()<<8|Wire.read();  // Aceleração em Z
    
  //Temperatura em ºC
  Tmp=Wire.read()<<8|Wire.read();
  Tmp = Tmp/340.00+36.53; //Conversão para ºC
  
  //Dados do giroscópio  
  GyX=Wire.read()<<8|Wire.read();  // Inclinação em X
  GyY=Wire.read()<<8|Wire.read();  // Inclinação em Y
  GyZ=Wire.read()<<8|Wire.read();  // Inclinação em Z

  //recebendo e pressão(pres) altura relativa ao solo a partir do BMP
  char status;
  double T, P, alt, pres; //Temperatura e pressão utilizadas para cálculo da altura, altura, pressão
  status = bmp180.startTemperature();
  if (status != 0) 
  {
    delay(100);
    status = bmp180.getTemperature(T);

    if (status != 0) 
    {
      status = bmp180.startPressure(3);

      if (status != 0) 
      {
        delay(status);
        status = bmp180.getPressure(P, T);
        pres = status;
        if (status != 0) 
        {
          alt = bmp180.altitude(P, Po);
        }
      }
    }
   }
  

  //Salvando dados no cartão sd
  meuArquivo.print(alt);
  meuArquivo.print(",");  
  meuArquivo.print(pres);
  meuArquivo.print(",");
  meuArquivo.print(Tmp);
  meuArquivo.print(",");
  meuArquivo.print(AcX);
  meuArquivo.print(",");
  meuArquivo.print(AcY);
  meuArquivo.print(",");
  meuArquivo.print(AcZ);
  meuArquivo.print(",");
  meuArquivo.print(GyX);
  meuArquivo.print(",");
  meuArquivo.print(GyY);
  meuArquivo.print(",");
  meuArquivo.println(GyZ);

  //Abertura paraquedas("l")
  if (Serial.available())
  {
   String valor = Serial.read();
  }
  if (valor == 'l')
  {
  paraquedas.write(90);;
  }
  else if (valor == 'd')
  {
  paraquedas.write(0);;
  }

  //Printando dados no serial
  Serial.print(alt);
  Serial.print(",");  
  Serial.print(pres);
  Serial.print(",");
  Serial.print(Tmp);
  Serial.print(",");
  Serial.print(AcX);
  Serial.print(",");
  Serial.print(AcY);
  Serial.print(",");
  Serial.print(AcZ);
  Serial.print(",");
  Serial.print(GyX);
  Serial.print(",");
  Serial.print(GyY);
  Serial.print(",");
  Serial.println(GyZ);  

  //Recebendo dados 
  if (radio.available()) 
  { 
    char text[1] = ""; 
    radio.read(&text, sizeof(text)); /
    Serial.println(text); 
  }

  //enviando dados
  const char text[] = alt +"," + pres + "," + Tmp + "," + AcX + "," + AcY + "," + AcZ + "," + GyX + "," + GyY + "," + GyZ; 
  radio.write(&text); 

  
  delay(20);
 
}
