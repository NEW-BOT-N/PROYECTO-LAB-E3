library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MODULO is
	Generic(
		TT: Integer := 240000
	);
	Port (
		clk: in STD_LOGIC;
		SWITCH: in STD_LOGIC;											--ALARMA
		OUT_DISPLAY: out STD_LOGIC_VECTOR( 7 downto 0);			--(DISPLAY)
		IO_P2: in STD_LOGIC_VECTOR(7 downto 0);					--(LDR_ENTRADA:IOP20-IOP21)(LDR_SALIDA:IOP22-IOP23)(PDR:IP24-IP27)
		IO_P4: in STD_LOGIC_VECTOR(7 downto 0);					--(PFT:IP40-IP43)(PIZ:IOP44-IOP47)			
		IO_P6: out STD_LOGIC_VECTOR(7 downto 3);					--(SERVO1:IP20-IP21:IP63)(SERVO2:IP22-IP23:IP64)(IP24-IP27:IP65)(IOP40-IOP43:IOP66)(IP44-IP47:IP67)
		ENABLE_DISPLAY: out STD_LOGIC_VECTOR ( 0 to 2)	);
end MODULO;

architecture Behavioral of MODULO is

	Signal DISPLAY: integer range 0 to 9;
	signal UNIDADES, DECENAS: integer range 0 to 9;
	signal COUNTMULTIPLEX: integer range 0 to 120000;
	signal SELECTMULTIPLEX: std_logic;
	Signal PFT,PIZ,PDR: integer range 0 to 4;	
	signal PDISPONIBLES : integer range 0 to 12;
	signal OUTCONTROL: integer:= 0 ;
	signal OUTCONTROL2: integer:= 0 ;
	signal INCONTROL: integer:= 0 ;
	signal INCONTROL2: integer:= 0 ;
	signal ALARMA: std_logic:= '0';	
	signal COUNTSERVO1: integer range 0 to TT;
	signal COUNTSERVO2: integer range 0 to TT;
	signal TASERVO1: integer range 0 to TT;	
	signal TASERVO2: integer range 0 to TT;
begin
process(clk)
	begin		

		if rising_edge (clk) then
			if SWITCH = '0' then
				ALARMA <= not(ALARMA);
			end if;
			
			while ALARMA = '1' loop
				TASERVO1 <= 18000;
				TASERVO2 <= 18000;
				end loop;
			while ALARMA = '0' loop	
		   if INCONTROL = 0 and INCONTROL2 = 0 and IO_P2(0) = '0' and IO_P2(1) = '0'  then
				TASERVO1 <= 8010;			
				INCONTROL <= 0;
				INCONTROL2 <= 0;
			elsif INCONTROL = 0 and INCONTROL2 = 0 and IO_P2(0) = '1' and IO_P2(1) = '0'  then
				TASERVO1 <= 18000;			
				INCONTROL <= 1;
				INCONTROL2 <= 0;
			elsif INCONTROL = 1 and INCONTROL2 = 0 and IO_P2(0) = '0' and IO_P2(1) = '0'  then
				TASERVO1 <= 18000;			
				INCONTROL <= 1;
				INCONTROL2 <= 0;
			elsif INCONTROL = 1 and INCONTROL2 = 0 and IO_P2(0) = '0' and IO_P2(1) = '1'  then
				TASERVO1 <= 18000;			
				INCONTROL <= 1;
				INCONTROL2 <= 1;
			elsif INCONTROL = 1 and INCONTROL2 = 1 and IO_P2(0) = '0' and IO_P2(1) = '0'  then
				TASERVO1 <= 8010;			
				INCONTROL <= 0;
				INCONTROL2 <= 0;
			end if;			

			
			if OUTCONTROL = 0 and OUTCONTROL2 = 0 and IO_P2(2) = '0' and IO_P2(3) = '0'  then
				TASERVO2 <= 8010;			
				OUTCONTROL <= 0;
				OUTCONTROL2 <= 0;
			end if;
			if OUTCONTROL = 0 and OUTCONTROL2 = 0 and IO_P2(2) = '1' and IO_P2(3) = '0'  then
				TASERVO2 <= 18000;			
				OUTCONTROL <= 1;
				OUTCONTROL2 <= 0;
			end if;
			if OUTCONTROL = 1 and OUTCONTROL2 = 0 and IO_P2(2) = '0' and IO_P2(3) = '0'  then
				TASERVO2 <= 18000;			
				OUTCONTROL <= 1;
				OUTCONTROL2 <= 0;
			end if;
			if OUTCONTROL = 1 and OUTCONTROL2 = 0 and IO_P2(2) = '0' and IO_P2(3) = '1'  then
				TASERVO2 <= 18000;			
				OUTCONTROL <= 1;
				OUTCONTROL2 <= 1;
			end if;
			if OUTCONTROL = 1 and OUTCONTROL2 = 1 and IO_P2(2) = '0' and IO_P2(3) = '0'  then
				TASERVO2 <= 8010;			
				OUTCONTROL <= 0;
				OUTCONTROL2 <= 0;
			end if;	
			end loop;
			
			if(COUNTSERVO1<TASERVO1) then
				IO_P6(3)<='1';
			else
				IO_P6(3)<='0';
			end if;
			
			if(COUNTSERVO2<TASERVO2) then
				IO_P6(4)<='1';
			else
				IO_P6(4)<='0';
			end if;

			if(COUNTSERVO1=TT-1) then
				COUNTSERVO1<=0;
			else
				COUNTSERVO1<=COUNTSERVO1+1;
			end if;			
		
			if(COUNTSERVO2=TT-1) then
				COUNTSERVO2<=0;
			else
				COUNTSERVO2<=COUNTSERVO2+1;
			end if;			
		
			PIZ <= CONV_INTEGER(IO_P4(4))+CONV_INTEGER(IO_P4(5))+CONV_INTEGER(IO_P4(6))+CONV_INTEGER(IO_P4(7));
			if (PIZ <= 3) then 
				IO_P6(7) <='1';
			else
				IO_P6(7) <='0';
			end if;
			PFT <= CONV_INTEGER(IO_P4(0))+CONV_INTEGER(IO_P4(1))+CONV_INTEGER(IO_P4(2))+CONV_INTEGER(IO_P4(3));
			if (PFT <= 3) then 
				IO_P6(6) <= '1';
			else
				IO_P6(6) <= '0';
			end if;
			PDR <= CONV_INTEGER(IO_P2(4))+CONV_INTEGER(IO_P2(5))+CONV_INTEGER(IO_P2(6))+CONV_INTEGER(IO_P2(7));
			if (PDR <= 3) then 
				IO_P6(5) <='1';
			else
				IO_P6(5) <='0';
			end if;
			
			PDISPONIBLES <= 12-(PFT+PIZ+PDR);
			if (PDISPONIBLES >= 10) then 
				UNIDADES <=PDISPONIBLES-10;
				decenas <=1;
			end if;
			if (PDISPONIBLES <= 9) then 
				UNIDADES <=PDISPONIBLES;
				DECENAS <=0;
			end if;

			if (COUNTMULTIPLEX = 20000) then
			COUNTMULTIPLEX <= 0;
			SELECTMULTIPLEX <= not(SELECTMULTIPLEX);
			if SELECTMULTIPLEX = '0' then
				DISPLAY <= UNIDADES;
				ENABLE_DISPLAY <="110";
			else
				DISPLAY <= DECENAS;
				ENABLE_DISPLAY <= "101";
			end if;
			else
				COUNTMULTIPLEX<= COUNTMULTIPLEX +1;
			end if;

		
		case DISPLAY is
									---hgfedcba
			when 0 => OUT_DISPLAY <= "11000000";
			when 1 => OUT_DISPLAY <= "11111001";
			when 2 => OUT_DISPLAY <= "10100100";
			when 3 => OUT_DISPLAY <= "10110000";
			when 4 => OUT_DISPLAY <= "10011001";
			when 5 => OUT_DISPLAY <= "10010010";
			when 6 => OUT_DISPLAY <= "10000010";
			when 7 => OUT_DISPLAY <= "11111000";
			when 8 => OUT_DISPLAY <= "10000000";
			when 9 => OUT_DISPLAY <= "10011000";
			when others => OUT_DISPLAY <="11111111";
		end case;
		
		
	end if;	
		
			
	end process;



end Behavioral;

