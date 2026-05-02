// Define the type for the commands object
interface Commands {
  [key: string]: {
    [key: string]: {
      name: string,
      args: string[]
    }
  }
}

// Define the commands for each platform
const cmds: Commands = {
  windows: {
    shutdown: {name: "shutdown", args: ["/s", "/t", "00"]},
    reboot: {name: "shutdown", args: ["/r", "/t", "00"]},
    sleep: {name: "rundll32.exe", args: ["powrprof.dll,SetSuspendState", "0,1,0"]},
    lock: {name: "rundll32.exe", args: ["user32.dll,LockWorkStation"]}
  },
  linux: {
    shutdown: {name: "sudo", args: ["shutdown", "-h", "now"]},
    reboot: {name: "sudo", args: ["reboot"]},
    sleep: {name: "sudo", args: ["systemctl", "suspend"]},
    lock: {name: "xdg-screensaver", args: ["lock"]}
  }
}

// Find device IPv4 address
const pattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
const ip = Deno.networkInterfaces().find((i) => pattern.test(i.address))?.address || "localhost"

// Start the server
Deno.serve({
  port: 7421,
  hostname: "0.0.0.0",
  onListen: () => { console.log(`[ShutApp] Listening on ws://${ip}:7421`) }
}, (req) => {
  // Handle WebSocket connections
  if (req.headers.get("upgrade") === "websocket") {
    const { socket, response } = Deno.upgradeWebSocket(req);

    // Handle WebSocket messages
    socket.onmessage = (e) => {
      if(e.data === "ping") {
        const data: { hostname: string, os: string } = { hostname: Deno.hostname(), os: Deno.build.os };
        return socket.send(JSON.stringify(data));
      }

      if(Object.keys(cmds).includes(Deno.build.os)) {
        const commands = cmds[Deno.build.os as keyof typeof cmds];

        if(Object.keys(commands).includes(e.data)) {
          const command = commands[e.data as keyof typeof commands];
          new Deno.Command(command.name, { args: command.args }).outputSync();
        } else {
          socket.close(400, "Unsupported command")
        }
      } else {
        socket.close(500, "Unsupported OS")
      }
    };

    return response;
  }

  // Handle other requests
  const defaultResponse: string = `Failed to open a WebSocket connection: invalid Connection header: ${req.headers.get("connection")}.
You cannot access a WebSocket server directly with a browser. You need a WebSocket client.`
  
  return new Response(defaultResponse, { status: 400 })
});