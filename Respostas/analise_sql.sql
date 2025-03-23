--------------------------------------------------------------------------------------------------------
-- Questão 1:
-- Quantos chamados foram abertos no dia 01/04/2023?

SELECT COUNT(*) FROM 
  `datario.adm_central_atendimento_1746.chamado` 
WHERE 
  data_inicio >= "2023-04-01 00:00:00" 
  AND 
  data_inicio < "2023-04-02 00:00:00";
-- Resposta: 1903 Ocorrências. 

--------------------------------------------------------------------------------------------------------

-- Questão 2:
-- Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?

SELECT tipo, COUNT(*) AS total_chamados FROM 
  `datario.adm_central_atendimento_1746.chamado` 
WHERE 
  data_inicio >= '2023-04-01 00:00:00' 
  AND 
  data_inicio < '2023-04-02 00:00:00' 
GROUP BY tipo ORDER BY total_chamados DESC;
-- Resposta: Estacionamento irregular com 373 ocorrêcias.

--------------------------------------------------------------------------------------------------------

-- Questão 3:
-- Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

SELECT 
  b.nome AS nome_bairro, 
  COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` AS c
LEFT JOIN `datario.dados_mestres.bairro` AS b
  ON c.id_bairro = b.id_bairro
WHERE c.data_inicio >= '2023-04-01 00:00:00' 
AND c.data_inicio < '2023-04-02 00:00:00'
GROUP BY nome_bairro
ORDER BY total_chamados DESC LIMIT 4;
-- Resposta: 
/*
|-----------------------------|
|  null            |  131     |
|-----------------------------|
|  Campo Grande    |  124     |
|-----------------------------|
|  Tijuca          |  96      |
|-----------------------------|
|  Barra da Tijuca |  60      |
|-----------------------------|
Foram encontradas ocorrências com null que podem ser desprezadas. 
*/

--------------------------------------------------------------------------------------------------------

-- Questão 4:
-- Qual o nome da subprefeitura com mais chamados abertos nesse dia?

SELECT b.subprefeitura AS nome_subprefeitura, COUNT(*) AS total_chamados FROM 
  `datario.adm_central_atendimento_1746.chamado` AS c
LEFT JOIN 
  `datario.dados_mestres.bairro` AS b
  ON 
    c.id_bairro = b.id_bairro
WHERE 
  c.data_inicio >= '2023-04-01 00:00:00' 
AND 
  c.data_inicio < '2023-04-02 00:00:00'
GROUP BY 
  nome_subprefeitura
ORDER BY 
  total_chamados DESC;
-- Resposta: 
/*
|-------------------|
| Zona norte  | 534 |
'-------------------'
*/

--------------------------------------------------------------------------------------------------------

-- Questão 5:
-- Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

SELECT 
  COUNT(*) AS total_chamados_sem_bairro
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE 
  data_inicio >= '2023-04-01 00:00:00' 
AND 
  data_inicio < '2023-04-02 00:00:00'
AND 
  id_bairro IS NULL;
-- Resposta: 
-- Sim, existe 131 chamados da tabela Chamados aberto nesse dia que não possui id_bairro (valor null na coluna id_bairro) e, por isso, não pode ser 
-- associado a nenhum registro da tabela Bairro, o que inclui tanto bairro quanto subprefeitura.

--------------------------------------------------------------------------------------------------------

-- Questão 6:
-- Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

SELECT 
  COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE 
  tipo = "Perturbação do sossego"
AND 
  data_inicio BETWEEN '2022-01-01' AND '2023-12-31'
-- Resposta: 66051 chamados foram abertos nesta data

--------------------------------------------------------------------------------------------------------
-- Questão 7:
-- Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
SELECT 
    c.id_chamado,
    c.data_inicio AS data_chamado,
    e.evento
FROM `datario.adm_central_atendimento_1746.chamado` AS c
JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    ON c.data_inicio BETWEEN e.data_inicial AND e.data_final
WHERE c.tipo = "Perturbação do sossego"
AND e.data_inicial IS NOT NULL
AND e.data_final IS NOT NULL
AND c.data_inicio BETWEEN '2022-01-01' AND '2023-12-31'
ORDER BY c.data_inicio ASC;

--------------------------------------------------------------------------------------------------------
-- Questão 8: 
-- Quantos chamados desse subtipo foram abertos em cada evento?

SELECT 
    e.evento,
    COUNT(c.id_chamado) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` AS c
JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    ON c.data_inicio BETWEEN e.data_inicial AND e.data_final
WHERE c.tipo = "Perturbação do sossego"
AND e.data_inicial IS NOT NULL
AND e.data_final IS NOT NULL
AND c.data_inicio BETWEEN '2022-01-01' AND '2023-12-31'
GROUP BY e.evento
ORDER BY total_chamados DESC;
/*
  Resposta: 
|----------------------------|  
| Evento      | Ocorrências  | 
|----------------------------|
| Rock in Rio | 633          |
|----------------------------|
| Carnaval    | 355          |
|----------------------------|
| Réveillon   | 162          |
'----------------------------'
*/

--------------------------------------------------------------------------------------------------------

-- Questão 9:
-- Qual evento teve a maior média diária de chamados abertos desse subtipo?

SELECT 
    e.evento,
    COUNT(c.id_chamado) / (DATE_DIFF(e.data_final, e.data_inicial, DAY) + 1) AS media_diaria_chamados
FROM `datario.adm_central_atendimento_1746.chamado` AS c
JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
    ON c.data_inicio BETWEEN e.data_inicial AND e.data_final
WHERE c.tipo = "Perturbação do sossego"
AND e.data_inicial IS NOT NULL
AND e.data_final IS NOT NULL
AND c.data_inicio BETWEEN '2022-02-01' AND '2023-12-31'
GROUP BY e.evento, e.data_inicial, e.data_final
ORDER BY media_diaria_chamados DESC;
-- Resposta: Rock in Rio com média de 96,5 chamados por dia, feitos no primeiro fim de semana do evento. 
/*

| Evento        | Ano  | Chamados |Duração | Média              |
|---------------|------|----------|--------|--------------------|
|  Rock in Rio  |2022  | 386      | 4      | 96.5               |
|---------------|------|----------|--------|--------------------|
|  Rock in Rio  |2022  | 247      | 3      | 82.333333333333329 |
|---------------|------|----------|--------|--------------------|
|  Carnaval     |2023  | 221      | 4      | 55.25              |
|---------------|------|----------|--------|--------------------|
|  Réveillon    |2022  | 94       | 3      | 31.333333333333332 |
|---------------|------|----------|--------|--------------------|
|  Réveillon    |2023  | 41       | 3      | 13.66666666666666  |
|---------------------------------------------------------------|
	
*/
--------------------------------------------------------------------------------------------------------

-- Questão 10:
-- Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.
WITH eventos_chamados AS (
    SELECT 
        e.evento,
        COUNT(c.id_chamado) AS total_chamados,
        DATE_DIFF(e.data_final, e.data_inicial, DAY) + 1 AS duracao_evento_dias
    FROM `datario.adm_central_atendimento_1746.chamado` AS c
    JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS e
        ON c.data_inicio BETWEEN e.data_inicial AND e.data_final
    WHERE c.tipo = "Perturbação do sossego"
        AND e.data_inicial IS NOT NULL
        AND e.data_final IS NOT NULL
        AND c.data_inicio BETWEEN '2022-01-01' AND '2023-12-31'
    GROUP BY e.evento, e.data_inicial, e.data_final
), 

media_geral AS (
    SELECT COUNT(*) / 730 AS media_diaria_geral
    FROM `datario.adm_central_atendimento_1746.chamado`
    WHERE tipo = "Perturbação do sossego"
    AND data_inicio BETWEEN '2022-01-01' AND '2023-12-31'
)

SELECT 
    e.evento,
    SUM(e.total_chamados) AS total_chamados_evento,
    SUM(e.duracao_evento_dias) AS total_dias_evento,
    SUM(e.total_chamados) / SUM(e.duracao_evento_dias) AS media_diaria_evento,
    mg.media_diaria_geral,
    (SUM(e.total_chamados) / SUM(e.duracao_evento_dias)) / mg.media_diaria_geral AS fator_variacao,
    ((SUM(e.total_chamados) / SUM(e.duracao_evento_dias)) / mg.media_diaria_geral - 1) * 100 AS variacao_percentual
FROM eventos_chamados e
CROSS JOIN media_geral mg
GROUP BY e.evento, mg.media_diaria_geral
ORDER BY variacao_percentual DESC;
/*
|--------------------------------------------------------------------------------------------------------------------|
|Evento       |Chamados |Dias | Média diária       | Média geral        |Fator variação      |  variação percentual  |
|-------------|---------|-----|--------------------|--------------------|--------------------|-----------------------|
|Rock in Rio  |633      |7    | 90.428571428571431 | 90.480821917808214 | 0.999422524153414  | -0.057747584658596196 |	
|-------------|---------|-----|--------------------|--------------------|--------------------|-----------------------|
|Carnaval     |221      |4    | 55.25              | 90.480821917808214 | 0.610626636992627  | -38.9373363007373     |
|-------------|---------|-----|--------------------|--------------------|--------------------|-----------------------|
|Réveillon    |135      |6    | 22.5               | 90.480821917808214 | 0.24867148112821913| -75.132851887178091   |
|--------------------------------------------------------------------------------------------------------------------|
*/
--------------------------------------------------------------------------------------------------------