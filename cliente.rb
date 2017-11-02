require 'faraday'

class Cliente
  def initialize(usuario)
    @usuario = usuario
    @nodo = @usuario.split('@').last
  end

  def publicar(mensaje, destinatarios)
    Faraday.post(
      "#{@nodo}/outbox",
      mensaje: mensaje,
      destinatarios: destinatarios
    ).body
  end
end
