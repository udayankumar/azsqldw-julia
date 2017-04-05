using ODBC,  ArgParse


function main(args)

    s = ArgParseSettings(description ="Example usage")
    @add_arg_table s begin
        "sqlconnection"
            help = "ODBC Connection String to Azure, you can get this from the Azure Portal or using the CLI"
            required = true
    end

    parsed_args  = parse_args(s)
    sql_connection = parsed_args["sqlconnection"]

    println("SQL Conection String : $sql_connection")

    @show ODBC.listdrivers()
    @show ODBC.listdsns()

    dsndw = ODBC.DSN(sql_connection)

    ODBC.execute!(dsndw, "create table test1
                        (test_bigint bigint,
                        test_bit bit,
                        test_decimal decimal,
                        test_int int
                        )")

    @time ODBC.execute!(dsndw, "insert test1 VALUES
                        (1, -- bigint
                        1, -- bit
                        1.0, -- decimal
                        1)")

    dataset = ODBC.query(dsndw, "select * from test1")

    println("Dataset Retrieved from  DW")
    println(dataset)

    ODBC.execute!(dsndw, "drop table test1")

end

main(ARGS)
