import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.ServerSocket;
import java.nio.ByteBuffer;

public class JavaPlotServer extends Thread
{

	private enum Command
	{
		Function((byte)0),
		Data((byte)1),
		Done((byte)2),
		Close((byte)3);

		public final byte value;
		private Command(byte value)
		{
			this.value = value;
		}
	}

	private enum Function
	{
		Plot((byte)0),
		Figure((byte)1),
		SetupPlot((byte)2),
		Print((byte)3),
		Xlabel((byte)4),
		Ylabel((byte)5),
		Title((byte)6),
		Subplot((byte)7),
		Legend((byte)8),
		Hold((byte)9),
		Axis((byte)10),
		Grid((byte)11),
		Contour((byte)12),
		Colorbar((byte)13),
		Semilogx((byte)14),
		Semilogy((byte)15),
		Loglog((byte)16);

		public final byte value;
		private Function(byte value)
		{
			this.value = value;
		}
	}

	private enum ServerResponce
	{
		Ok((byte)0),
		MoreBytes((byte)1),	// depricated
		Exception((byte)2),
		Connected((byte)3),
		Disconnecting((byte)4);

		public final byte value;
		private ServerResponce(byte value)
		{
			this.value = value;
		}
	}

	int port;

	public JavaPlotServer(int port)
	{
		this.port = port;    
	}

	@Override
	public void run()
	{
		try
		{
			System.out.println("Starting server on ");
			ServerSocket server = new ServerSocket(port);
			Socket client = server.accept();

			InputStream in = client.getInputStream();
			OutputStream out = client.getOutputStream();

			long currentPayload = 10;

			byte[] responce = {ServerResponce.Ok.value, (byte)255, (byte)255, (byte)255, (byte)255};
			byte[] data = new byte[(int)currentPayload];

			out.write(responce);

			while(true)
			{
				long bytesRead = in.read(data, 0, (int)currentPayload);
				while(bytesRead < currentPayload)
				{
					long bytesReadAgain = in.read(data, (int)bytesRead, (int)(currentPayload - bytesRead));
					bytesRead += bytesReadAgain;
				}

				byte[] sizeBytes = ByteBuffer.allocate(4).putInt((int)(bytesRead & 0x00000000FFFFFFFF)).array();
				responce = new byte[]{ServerResponce.Ok.value, sizeBytes[0], sizeBytes[1], sizeBytes[2], sizeBytes[3]};

				out.write(responce);

				//switch()
			}

		} catch (Exception ex) {
			System.out.println(ex.toString());
		}
	}
}