use Biblioteca;
SET GLOBAL log_bin_trust_function_creators = 1;
Delimiter $
create function livros_disponiveis (livro_id int)
returns int
begin
declare total_exemplares int;
declare exemplares_emprestados int;
declare exemplares_disponiveis int;
select quantidade into total_exemplares from Livros where Id_livro = livro_id;
select count(*) into exemplares_emprestados from Emprestimos where livro_id = livro_id;
select total_exemplares - exemplares_emprestados into exemplares_disponiveis;
return exemplares_disponiveis;
end$
delimiter ;

drop procedure if exists RegistrarEmprestimo;
delimiter $
create procedure RegistrarEmprestimo(
in livro_id int,
in usuario_id int,
in Data_emprestimo date,
in Data_devolucao date
)
begin
declare exemplares_disponiveis int;
select (quantidade - count(Id_emprestimo)) into exemplares_disponiveis from Livro 
left join Emprestimo on Id_livro = e.livro_id where Id_livro = livro_id;

if exemplares_disponiveis > 0 then 
insert into Emprestimo values (livro_id, usuario_id, Data_emprestimo, Data_devolucao);
else
signal sqlstate '45000'set message_text = 'Nao ha exemplares disponiveis para emprestimo';

end if;
end$
delimiter ;

create view DetalheEmprestimo as
select 
Id_emprestimo,
DataRetirada,
DataDevolucao,
fk_autorid,
fk_livroid
from Emprestimo;

alter view detalheemprestimo
as select Id_emprestimo as Codigo_emprestimo,
DataRetirada as Retirada,
DataDevolucao as Devolucao,
fk_autorid as Codigo_Autor,
fk_livroid as Codigo_livro
from Emprestimo

