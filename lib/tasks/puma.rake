APP_ROOT = File.dirname(File.dirname(File.realpath(__FILE__)))
PID_DIR = File.join(APP_ROOT, "tmp", "pids")
PID_FILE = File.join(PID_DIR, "puma.pid")
SOCKET_DIR = File.join(APP_ROOT, "tmp", "sockets")
SOCKET_FILE = File.join(SOCKET_DIR, "puma.socket")

`mkdir -p "#{PID_DIR}"` unless File.exists?(PID_DIR)
`mkdir -p "#{SOCKET_DIR}"` unless File.exists?(SOCKET_DIR)

def puma_is_running?
  return 0 unless File.exists?(SOCKET_FILE)
  begin
    pid = File.open(PID_FILE, &:readline)
    Process.getpgid(pid.to_i)
    pid.to_i
  rescue
    0
  end
end

def start_puma
  system "bundle exec puma -e production -b unix://#{SOCKET_FILE} --pidfile #{PID_FILE} -d"
  sleep 1
  if puma_is_running? > 0
    STDOUT.puts "Puma is running now."
  else
    STDERR.puts "Error starting puma."
  end
end

namespace :puma do
  desc 'Start Puma'
  task :start do
    if puma_is_running? > 0
      STDOUT.puts "Puma is already running. Nothing to do."
    else
      start_puma
    end
  end

  desc 'Stop Puma'
  task :stop do
    if puma_is_running? > 0
      begin
        pid = File.open(PID_FILE, &:readline).to_i
        Process.kill "TERM", pid
        system "rm -f #{PID_FILE}"
        system "rm -f #{SOCKET_FILE}"
        sleep 1
        begin
          Process.getpgid(pid.to_i)
          STDERR.puts "You may have to kill the puma process manually."
        rescue Errno::ESRCH
          STDOUT.puts "Puma is stopped. Process with PID=#{pid} has been killed."
        end
      rescue
        STDERR.puts "Error stopping puma."
      end
    else
      STDERR.puts "No puma is running. Nothing to do."
    end
  end

  desc 'Restart Puma'
  task :restart do
    pid = puma_is_running?
    if pid > 0
      STDOUT.puts "Puma is restarting..."
      Process.kill "USR2", pid
      sleep 5
      new_pid = puma_is_running?
      if new_pid > 0 and new_pid != pid
        STDOUT.puts "Puma has been restarted successfully. From PID=#{pid} to PID=#{new_pid}."
      else
        STDERR.puts "Error restarting puma."
      end
    else
      start_puma
    end
  end

  desc 'Check Puma Status'
  task :status do
      pid = puma_is_running?
      STDOUT.puts <<EOF
  APP ROOT     :  #{APP_ROOT} [exists? = #{File.exists?(APP_ROOT)}]
  PID FILE     :  #{PID_FILE} [exists? = #{File.exists?(PID_FILE)}]
  SOCKET FILE  :  #{SOCKET_FILE} [exists? = #{File.exists?(SOCKET_FILE)}]
  RUNNING?     :  #{pid > 0 ? "YES, PID=#{pid}" : "NO"}
EOF
  end
end
