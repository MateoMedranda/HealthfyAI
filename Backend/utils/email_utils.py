import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import config
import threading

def _send_email_thread(to_email: str, subject: str, html_content: str):
    """
    Envia el email en un hilo separado para no bloquear el event loop principal.
    """
    try:
        message = MIMEMultipart("alternative")
        message["Subject"] = subject
        message["From"] = config.EMAIL_FROM
        message["To"] = to_email

        part = MIMEText(html_content, "html")
        message.attach(part)

        # Conexión segura con TLS
        server = smtplib.SMTP(config.SMTP_SERVER, config.SMTP_PORT)
        server.starttls()
        server.login(config.SMTP_USERNAME, config.SMTP_PASSWORD)
        server.sendmail(config.EMAIL_FROM, to_email, message.as_string())
        server.quit()
        print(f"✅ Email enviado correctamente a {to_email}")
    except Exception as e:
        print(f"❌ Error enviando email a {to_email}: {str(e)}")

def send_password_reset_email(to_email: str, token: str):
    """
    Envia un correo de restablecimiento de contraseña.
    """
    subject = "Restablecimiento de Contraseña - HealthfyAI"
    
    # En un caso real, esto sería un link al frontend, pero por ahora enviaremos el token
    # O un Deep Link si la app lo soporta.
    # Dado que es una app móvil, idealmente sería un Deep Link o un código corto.
    # Para este MVP, asumiremos que el usuario copiará el token (o código) en la app.
    
    html_content = f"""
    <html>
      <body style="font-family: Arial, sans-serif; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #6C63FF; text-align: center;">Restablece tu Contraseña</h2>
          <p>Hola,</p>
          <p>Hemos recibido una solicitud para restablecer la contraseña de tu cuenta en <strong>HealthfyAI</strong>.</p>
          <p>Para continuar, utiliza el siguiente código o token en la aplicación:</p>
          
          <div style="background-color: #f4f4f4; padding: 15px; border-radius: 5px; text-align: center; font-family: monospace; font-size: 18px; margin: 20px 0;">
            {token}
          </div>
          
          <p>Este código expira en 15 minutos.</p>
          <p>Si no solicitaste este cambio, puedes ignorar este correo.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #999; text-align: center;">Este es un mensaje automático, por favor no respondas.</p>
        </div>
      </body>
    </html>
    """
    
    # Ejecutar en background thread
    threading.Thread(target=_send_email_thread, args=(to_email, subject, html_content)).start()
