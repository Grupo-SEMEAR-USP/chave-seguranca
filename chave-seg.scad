include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fa = 1;
$fs = 0.4;

com_buraco_parafuso_chave = false;
com_buraco_parafuso_fecha = false;

offset_de_parede = 0.001;
//Parametros (mm)
//// Parametros fisicos da chave
espessura_parede = 8;
espessura_tampa = 5;
espessura_chao = 1;

//// Parametros do contato com as placas de IO

largura_contato = 9;
altura_contato = 6;

//// Parametros do parafuso da chave
diametro_parafuso_chave_cabeca = 6;
diametro_parafuso_chave = 3.3;
comprimento_parafuso_chave_cabeca = 3.5;
comprimento_parafuso_chave = 15 - comprimento_parafuso_chave_cabeca;
pitch_parafuso_chave = .5;
largura_porca_parafuso_chave = 6;
altura_porca_parafuso_chave = 2.5;

//// Parametros da mola da chave
diametro_mola = 6;
comprimento_mola = 7;

assert(diametro_mola > diametro_parafuso_chave, "Buraco da mola esta menor que o buraco do parafuso!");

//// Parametros do parafuso para fechar
diametro_parafuso_fecha_cabeca = 6.2;
diametro_parafuso_fecha = 3.3;
comprimento_parafuso_fecha_cabeca = 3.5;
comprimento_parafuso_fecha = 12.5 - comprimento_parafuso_fecha_cabeca;
pitch_parafuso_fecha = .5;
largura_porca_parafuso_fecha = 6;
altura_porca_parafuso_fecha = 2.5;

assert(espessura_parede*2 > diametro_parafuso_fecha, "Buraco dos parafusos de fecha esta maior que a parede da chave!");
assert(espessura_parede*2 > diametro_parafuso_fecha_cabeca, "Buraco para a cabeca dos parafusos de fecha esta maior que a parede da chave!");

//// Parametros das placas da chave
tamanho_gap_chave = 1;
largura_placa = 8;
espessura_placa = 2; //.5
comprimento_placa_in = 9;
comprimento_placa_out = 9;
comprimento_placa_chave = 12;
comprimento_contato = 1;
comprimento_gap = comprimento_placa_chave - 2*comprimento_contato;
comprimento_espaco_placas = 2*espessura_placa + tamanho_gap_chave;

echo("Gap entre placas de ", comprimento_gap, " mm");
assert(comprimento_gap > diametro_mola, "Buraco da mola esta intercionando as placas de contato!");

//Operacao Eletrica Esperada
potencia_maxima_permitida = 1; //Watt
corrente_maxima_esperada = 10; //A

//Caracteristicas do material
resistencia_eletrica_do_material = 1.68*10e-8 / (10e-3); //Ohms*mm, Cu, T=20C
//     in           chave          out
//         ----------------------
// --------------           ---------------
resistencia_total = resistencia_eletrica_do_material * (
			(comprimento_placa_in + comprimento_placa_chave + comprimento_placa_out - 4*comprimento_contato) / (espessura_placa * largura_placa) +
			(4*espessura_placa) / (comprimento_contato*largura_placa));
echo("Resistencia Total Esperada de ", resistencia_total, " Ohms");

potencia_total = corrente_maxima_esperada ^ 2 * resistencia_total;
echo("Potencia Total Esperada de ", potencia_total, " Watts");

assert(potencia_total < potencia_maxima_permitida, "Potencia total acima da maxima permitida!");

//Medidas da chave
////Comprimento
comprimento_placas = comprimento_placa_in + comprimento_gap + comprimento_placa_out;
comprimento = comprimento_placas // Comprimento devido as placas
	    + 2*espessura_parede; // Comprimento devido a espessura da parede
////Largura
largura = largura_placa // Largura devida a largura da placa
	+ 2*espessura_parede; // Largura devido a espessura da parede
////Altura
altura_corpo =  comprimento_parafuso_chave + comprimento_espaco_placas;// Altura devido ao comprimento do parafuso e o gap que ele tem que atravesar para fechar o circuito

altura = altura_corpo + 2*espessura_tampa; // Altura devido a espessura da parede

//Confeccao do Modelo 3D
////Base da chave
cube([comprimento, largura, espessura_chao + offset_de_parede], anchor=BOTTOM);

////Corpo da chave
translate([0,0,espessura_chao]){
	difference(){
		cube([comprimento, largura, altura_corpo], anchor=BOTTOM);
		//Buraco do parafuso
		if(com_buraco_parafuso_chave){
			threaded_rod(d=diametro_parafuso_chave, height=altura_corpo + offset_de_parede, pitch=pitch_parafuso_chave, anchor=BOTTOM);
		}
		else{
			cylinder(altura_corpo + offset_de_parede, d=diametro_parafuso_chave, anchor=BOTTOM);
			translate([0,0, offset_de_parede + altura_porca_parafuso_chave/2])
			cube([largura_porca_parafuso_chave,largura_porca_parafuso_chave,altura_porca_parafuso_chave], anchor=CENTER);

		}

		//Espaco para as placas de metal
		inicio_do_espaco_placas = altura_corpo - comprimento_espaco_placas + offset_de_parede;
		translate([0,0, inicio_do_espaco_placas])
			cube([comprimento_placas, largura_placa, comprimento_espaco_placas], anchor=BOTTOM);

		//Buraco para as placas de IN e OUT
		inicio_buraco_placa_inout = inicio_do_espaco_placas + offset_de_parede - espessura_placa;
		offset_buraco_placa_inout = comprimento_placa_chave/2 - comprimento_contato + comprimento_placa_in / 2;
		////Buracao placa IN
		translate([-offset_buraco_placa_inout,0, inicio_buraco_placa_inout])
			cube([comprimento_placa_in, largura_placa, espessura_placa], anchor=BOTTOM);
		////Buracao placa OUT
		translate([offset_buraco_placa_inout,0, inicio_buraco_placa_inout])
			cube([comprimento_placa_out, largura_placa, espessura_placa], anchor=BOTTOM);

		//Buraco dos contatos para as placas IN e OUT

		translate([0,largura/2 - espessura_parede/2, inicio_buraco_placa_inout + espessura_placa/2]){
			//// IN
			translate([-offset_buraco_placa_inout,0,0])
				cube([largura_contato,espessura_parede + 2*offset_de_parede, altura_contato], anchor=BOTTOM);
			//// OUT
			translate([offset_buraco_placa_inout,0,0])
				cube([largura_contato,espessura_parede + 2*offset_de_parede, altura_contato], anchor=BOTTOM);
		}

		//Buraco da mola
		translate([0,0, inicio_do_espaco_placas - comprimento_mola + tamanho_gap_chave + offset_de_parede])
			cylinder(comprimento_mola + offset_de_parede, d=diametro_mola, anchor=BOTTOM);

		//Buracos pafarafusos para fechar
		comprimento_sobrando_para_parafuso_fechar = comprimento_parafuso_fecha + espessura_tampa - comprimento_parafuso_fecha_cabeca;
		for (i = [0:1], j = [0:1]) {
			translate([(-1)^i * (comprimento - espessura_parede) / 2, (-1)^j * (largura - espessura_parede) / 2, altura_corpo - comprimento_parafuso_fecha + espessura_tampa ])
			{
				if(com_buraco_parafuso_fecha){
				threaded_rod(d=diametro_parafuso_fecha, height=comprimento_sobrando_para_parafuso_fechar + offset_de_parede, pitch=pitch_parafuso_fecha, anchor=BOTTOM);
				}
				else{
			        cylinder(comprimento_sobrando_para_parafuso_fechar + offset_de_parede, d=diametro_parafuso_fecha, anchor=BOTTOM);
				translate([0,0, altura_porca_parafuso_fecha/2])
				cube([largura_porca_parafuso_fecha,largura_porca_parafuso_fecha, altura_porca_parafuso_fecha], anchor=CENTER);
				}
			}
		}


	}
}

//// Tampa da Chave
translate([largura*2,0,0,]){
	difference(){
	cube([comprimento, largura, espessura_tampa], anchor=BOTTOM);

	//Buraco do parafuso
	translate([0,0,-offset_de_parede])
		cylinder(d=diametro_parafuso_chave_cabeca * 1.1, h= espessura_tampa + offset_de_parede*2, anchor=BOTTOM);

	//Buracos pafarafusos para fechar
	for (i = [0:1], j = [0:1]) {
		translate([(-1)^i * (comprimento - espessura_parede) / 2, (-1)^j * (largura - espessura_parede) / 2, 0]){
			translate([0,0,-offset_de_parede])
				cylinder(d=diametro_parafuso_fecha * 1.1, h=espessura_tampa + offset_de_parede*2, anchor=BOTTOM);
			translate([0,0,espessura_tampa - comprimento_parafuso_fecha_cabeca])
				cylinder(d=diametro_parafuso_fecha_cabeca, h=comprimento_parafuso_fecha_cabeca + offset_de_parede, anchor=BOTTOM);
		}
	}
	}
}
