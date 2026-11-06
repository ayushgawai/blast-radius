select * from read_parquet('{{ env_var("EVENTS_PATH") }}')
