# **Contactless Cardio Monitor: a Contactless Cardiovascular Monitoring Software**

### **Autores: Lucas Macedo da Silva, Pedro Henrique de Brito Souza, Adson Ferreira da Rocha e Talles Marcelo G. de A. Barbosa**

### **Universidade: Pontifícia Universidade Católica de Goiás**

### **Trabalho de Conclusão de Curso**

---

## **Descrição**
O **Contactless Cardio Monitor (CCM)** trata-se de um monitor cardiovascular sem contato com o objetivo de monitorar variaveis cardiovasculares. O software é capaz de monitorar as seguintes variáveis:
* Frequência Cardíaca (FC);
* Variação da frequência Cardíaca (HRV);
* Tempo de Trânsito de Pulso (TTP);
* Velocidade da Onda de Pulso (VOP);
* Pressão Arterial (PA);
* Saturação do Oxigênio.

O software anteriormente denominado de HRVCAM foi desenvolvido a partir do trabalho desenvolvido por Pedro Henrique de Brito Souza, Adson Ferreira da Rocha, José Olímpio Ferreira e Talles Marcelo G. de A. Barbosa
> SOUZA, P. H. et al. HRVCam: A software for real-time feedback of heart rate and HRV. 2016 IEEE 6th International Conference on Computational Advances in Bio and Medical Sciences (ICCABS), p. 1–6, out. 2016.

O código do HRVCAM pode ser encontrado no [Github do HRVCAM](https://github.com/IsraelMachado/HRVCam)

O HRVCAM foi então melhorado permitindo a aquisição de novas variaveis além de melhorias nos cálculos, apresentação de dados, apresentação de resultados e melhorias de interface. Com isso, o CCM foi desenvolvido baseado no trabalho:
> DA SILVA, L. M. et al. Contactless Cardio Monitor: a Contactless Cardiovascular Monitoring Software. International Journal of Biotech Trends and Technology, v. 10, n. 4, p. 30–37, 25 dez. 2020.

---

## **Funcionamento**
O software calcula as variáveis a partir do sinal de fotopletismografia obtido a partir de uma câmera. Então baseado na variações do canais de cor é capaz de inferir as variáveis.
Ele funciona conforme descrito na Figura a seguir:

![image](https://github.com/user-attachments/assets/a03d8ab2-ca8a-4cde-9869-2b6ad11cc20b)

a) O usuário informa seus dados e configura o sistema, por exemplo, escolhe a resolução da câmera, conforme sua preferência;\
b) Definição das regiões de interesse e o sistema captura os dados;\
c) Processamento e cálculo, o sistema adquire o sinal e o processa conforme a variável escolhida;\
d) Caso o usuário tenha escolhido a opção salvar vídeo, no menu de configurações do sistema o sistema salva o vídeo e gera um relatório contendo as informações do usuário e a variável calculada.

---

### **Requisitos**

* Software Matlab R2018a ou superior com suporte:
  - “USB Webcam” (Matlab Addons)
  - “OS Generic Video Interface” (Matlab Addons);
* Webcam;
* Pacote Microsoft Word;
* Leitor de PDF;
* Matlab Runtime versão 9.8.


