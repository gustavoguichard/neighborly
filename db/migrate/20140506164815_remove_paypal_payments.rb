class RemovePaypalPayments < ActiveRecord::Migration
  def change
    drop_table :paypal_payments do |t|
      t.text :data
      t.text :hora
      t.text :fusohorario
      t.text :nome
      t.text :tipo
      t.text :status
      t.text :moeda
      t.text :valorbruto
      t.text :tarifa
      t.text :liquido
      t.text :doe_mail
      t.text :parae_mail
      t.text :iddatransacao
      t.text :statusdoequivalente
      t.text :statusdoendereco
      t.text :titulodoitem
      t.text :iddoitem
      t.text :valordoenvioemanuseio
      t.text :valordoseguro
      t.text :impostosobrevendas
      t.text :opcao1nome
      t.text :opcao1valor
      t.text :opcao2nome
      t.text :opcao2valor
      t.text :sitedoleilao
      t.text :iddocomprador
      t.text :urldoitem
      t.text :datadetermino
      t.text :iddaescritura
      t.text :iddafatura
      t.text :"idtxn_dereferência"
      t.text :numerodafatura
      t.text :numeropersonalizado
      t.text :iddorecibo
      t.text :saldo
      t.text :enderecolinha1
      t.text :enderecolinha2_distrito_bairro
      t.text :cidade
      t.text :"estado_regiao_território_prefeitura_republica"
      t.text :cep
      t.text :pais
      t.text :numerodotelefoneparacontato
      t.text :extra
      t.text :end
    end
  end
end
