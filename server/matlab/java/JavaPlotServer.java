import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.ServerSocket;
import java.nio.ByteBuffer;

import com.mathworks.jmi.Matlab;

public class JavaPlotServer extends Thread
{
	MatlabCommander matlabCommander = new MatlabCommander();
	
	private enum Command
	{
		None((byte)-1),
		Function((byte)0),
		Data((byte)1),
		Done((byte)2),
		Close((byte)3);

		public byte value;
		private Command(byte value)
		{
			this.value = value;
		}
	}

	private enum Function
	{
		None((byte)-1),
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
		Contourf((byte)13),
		Contour3((byte)14),
		Colorbar((byte)15),
		Semilogx((byte)16),
		Semilogy((byte)17),
		Loglog((byte)18);

		public byte value;
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
		Matlab.whenMatlabReady(matlabCommander);
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
			//byte[] data = new byte[(int)currentPayload];
			ByteBuffer data = ByteBuffer.allocate((int)currentPayload);

			out.write(responce);

			Command currentCommand = Command.None;
			Function currentFunction = Function.None;

			while(true)
			{
				long bytesRead = in.read(data.array(), 0, (int)currentPayload);
				while(bytesRead < currentPayload)
				{
					long bytesReadAgain = in.read(data.array(), (int)bytesRead, (int)(currentPayload - bytesRead));
					bytesRead += bytesReadAgain;
				}


				byte[] sizeBytes = ByteBuffer.allocate(4).putInt((int)(bytesRead & 0x00000000FFFFFFFF)).array();
				responce = new byte[]{ServerResponce.Ok.value, sizeBytes[0], sizeBytes[1], sizeBytes[2], sizeBytes[3]};

				out.write(responce);

				currentCommand.value = data.array()[0];

				//ByteBuffer dataBuffer = ByteBuffer.put(data);

				switch(currentCommand)
				{
					case Function:
						currentFunction.value = data.array()[1];
						currentPayload = data.getLong(2);
						break;

					case Data:
						switch(currentFunction)
						{
							case Plot:
								Plot(data, currentFunction);
								break;

							case Figure:
								Figure(data);
								break;

							case SetupPlot:
								SetupPlot(data);
								break;

							case Print:
								Print(data);
								break;

							case Xlabel:
								TextLabel(data, currentFunction);
								break;

							case Ylabel:
								TextLabel(data, currentFunction);
								break;

							case Title:
								TextLabel(data, currentFunction);
								break;

							case Subplot:
								Subplot(data);
								break;

							case Legend:
								Legend(data);
								break;
							case Hold:
								Hold(data);
								break;

							case Axis:
								Axis(data);
								break;

							case Grid:
								Grid(data);
								break;

							case Contour:
								Contour(data, currentFunction);
								break;
							case Contourf:
								Contour(data, currentFunction);
								break;

							case Contour3:
								Contour(data, currentFunction);
								break;

							case Colorbar:
								Colorbar(data);
								break;

							case Semilogx:
								Plot(data, currentFunction);
								break;

							case Semilogy:
								Plot(data, currentFunction);
								break;

							case Loglog:
								Plot(data, currentFunction);
								break;
						}
						break;

					case Done:
						currentPayload = 10;
						System.out.println("Got done command.");
						break;

					case Close:
						System.out.println("Connection closed.");
						break;

					case None:
						System.out.println("WHAT. THE. FUCK.");
						break;
				}
			}

		}
		catch (Exception ex)
		{
			System.out.println(ex.toString());
		}
	}

	void Plot(ByteBuffer data, Function func)
	{

	}

	void Figure(ByteBuffer data)
	{

	}

	void SetupPlot(ByteBuffer data)
	{

	}

	void Print(ByteBuffer data)
	{
		
	}

	void TextLabel(ByteBuffer data, Function func)
	{

	}

	void Subplot(ByteBuffer data)
	{
		
	}

	void Legend(ByteBuffer data)
	{
		
	}

	void Hold(ByteBuffer data)
	{
		
	}

	void Axis(ByteBuffer data)
	{
		
	}

	void Grid(ByteBuffer data)
	{
		
	}

	void Contour(ByteBuffer data, Function func)
	{
		
	}

	void Colorbar(ByteBuffer data)
	{
		
	}
}