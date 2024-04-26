---------------------------------------------------------------------------------------------
--
--	Universit� de Sherbrooke 
--  D�partement de g�nie �lectrique et g�nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr� T�trault
--					Daniel Dalle
--					S�bastien Roy
-- 
---------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; -- requis pour la fonction "to_integer"
use work.MIPS32_package.all;

entity MemDonnees is
Port ( 
	clk 		: in std_logic;
	reset 		: in std_logic;
	i_MemRead	: in std_logic;
	i_MemWrite 	: in std_logic;
	i_vec       : in std_logic;
    i_Addresse 	: in std_logic_vector (31 downto 0);
	i_WriteData : in std_logic_vector (127 downto 0);
    o_ReadData 	: out std_logic_vector (127 downto 0)
);
end MemDonnees;

architecture Behavioral of MemDonnees is
    signal ram_DataMemory : RAM(0 to 255) := ( -- type d�fini dans le package
------------------------
-- Ins�rez vos donnees ici
------------------------
X"00000003",
X"00000004",
X"00000002",
X"00000003",
X"00000005",
X"00000002",
X"00000002",
X"00000003",
X"00000003",
X"00000004",
X"00000002",
X"00000003",
X"00000003",
X"00000000",
X"00000004",
X"00000005",
X"00000002",
X"00000000",
X"00000002",
X"00000002",
X"ffffffff",
X"ffffffff",
X"ffffffff",
X"ffffffff",

------------------------
-- Fin de votre code
------------------------
    others => X"00000000");

    signal s_MemoryIndex 	: integer range 0 to 255; -- 0-127
	signal s_MemoryRangeValid 	: std_logic;

begin
    -- Transformation de l'adresse en entier � interval fix�s
    s_MemoryIndex 	<= to_integer(unsigned(i_Addresse(9 downto 2)));
	s_MemoryRangeValid <= '1' when i_Addresse(31 downto 10) = (X"10010" & "00") else '0';
	
	-- Partie pour l'�criture
	process( clk )
    begin
        if clk='1' and clk'event then
            if (i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1') then
                if (i_vec = '0') then
                    ram_DataMemory(s_MemoryIndex) <= i_WriteData(31 downto 0);
                else
                    ram_DataMemory(s_MemoryIndex + 3) <= i_WriteData(31 downto 0) ; --  when i_CmpData(31 downto 0 )  = x"FFFF";
                    ram_DataMemory(s_MemoryIndex + 2) <= i_WriteData(63 downto 32); --  when i_CmpData(63 downto 32)  = x"FFFF";
                    ram_DataMemory(s_MemoryIndex + 1) <= i_WriteData(95 downto 64); --  when i_CmpData(95 downto 64)  = x"FFFF";
                    ram_DataMemory(s_MemoryIndex)     <= i_WriteData(127 downto 96);--  when i_CmpData(127 downto 96) = x"FFFF";
                end if;
            end if;
        end if;
    end process;

    -- Valider que nous sommes dans le segment de m�moire, avec 256 addresses valides
    o_ReadData(31 downto 0)   <= ram_DataMemory(s_MemoryIndex + 3) when (s_MemoryRangeValid = '1' and i_MemRead = '1' and i_vec = '1')
                            else ram_DataMemory(s_MemoryIndex)     when (s_MemoryRangeValid = '1' and i_MeMRead = '1' and i_vec = '0')
                            else (others => '0');
                            
    o_ReadData(63 downto 32)  <= ram_DataMemory(s_MemoryIndex + 2) when (s_MemoryRangeValid = '1' and i_MemRead = '1' and i_vec = '1')
                                 else (others => '0');
    o_ReadData(95 downto 64)  <= ram_DataMemory(s_MemoryIndex + 1) when (s_MemoryRangeValid = '1' and i_MemRead = '1' and i_vec = '1')
                                 else (others => '0');
    o_ReadData(127 downto 96) <= ram_DataMemory(s_MemoryIndex)     when (s_MemoryRangeValid = '1' and i_MemRead = '1' and i_vec = '1')
                                 else (others => '0');

end Behavioral;
