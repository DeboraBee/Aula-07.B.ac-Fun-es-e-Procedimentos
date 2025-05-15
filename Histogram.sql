-- Procedimento 
CREATE PROCEDURE dbo.salaryHistogram
    @numBins INT
AS
BEGIN
    SET NOCOUNT ON;

-- variáveis para armazenar o salário mínimo e máximo
    DECLARE @minSalary FLOAT, @maxSalary FLOAT, @range FLOAT;

-- coletando o salário míinimo e máximo da tabela de professores 
    SELECT 
        @minSalary = MIN(salary),
        @maxSalary = MAX(salary)
    FROM instructor;

-- evita divisão por zero
    IF @numBins <= 0 OR @minSalary IS NULL OR @maxSalary IS NULL OR @minSalary = @maxSalary
    BEGIN
        PRINT 'Não é possível calcular o histograma com os valores fornecidos.';
        RETURN;
    END

-- calcula o intervalo (tamanho da faixa de salários)
    SET @range = (@maxSalary - @minSalary) / @numBins;

-- tabela temporária para armazenar os resultados 
    CREATE TABLE #Histogram (
        Intervalo VARCHAR(100),
        Frequencia INT
    );

    DECLARE @i INT = 0;
    WHILE @i < @numBins
    BEGIN
        DECLARE @lowerBound FLOAT = @minSalary + @i * @range;
        DECLARE @upperBound FLOAT = @lowerBound + @range;
        DECLARE @label VARCHAR(100) = 
            CONCAT(FORMAT(@lowerBound, 'N2'), ' - ', FORMAT(@upperBound, 'N2'));

-- conta quantos professores estão nesse intervalo 
        INSERT INTO #Histogram(Intervalo, Frequencia)
        SELECT 
            @label,
            COUNT(*) 
        FROM instructor
        WHERE salary >= @lowerBound AND 
              (salary < @upperBound OR (@i = @numBins - 1 AND salary <= @upperBound));

        SET @i += 1;
    END
-- exibe  o histograma
    SELECT * FROM #Histogram;
-- limpa a tabela temporária 
    DROP TABLE #Histogram;
END;

-- Execução exemplo
EXEC dbo.salaryHistogram 5;
