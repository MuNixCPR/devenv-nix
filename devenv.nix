{ pkgs, lib, config, ... }:

{
  # Python 3.12
  languages.python = {
    enable = true;
    package = pkgs.python312;
    venv = {
      enable = true;
      # Don't use automatic requirements installation due to relative path issues
      # requirements = ./requirements/local.txt;
    };
  };

  # Node 22
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
  };

  # PostgreSQL 14
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_14;
    initialDatabases = [{ name = "teleband"; }];
    initialScript = ''
      CREATE USER $USER WITH SUPERUSER;
    '';
    settings = {
      port = 5432;
    };
  };

  # Environment variables
  env = {
    DATABASE_URL = "postgres:///teleband";
    DJANGO_DEBUG = "True";
    DJANGO_SETTINGS_MODULE = "config.settings.local";
    SECRET = "idkjustpleasehavesomethingfortesting";
    NEXTAUTH_URL = "http://localhost:3000";
  };

  # Essential packages
  packages = with pkgs; [
    git
    gnumake
    gcc
    openssl
    readline
    sqlite
    xz
    zlib
    tcl
    tk
  ];

  # Scripts
  scripts = {
    "musiccpr-init" = {
      exec = ''
        echo "Setting up MusicCPR Backend..."
        
        # Ensure we're using the venv pip
        export PATH=".devenv/state/venv/bin:$PATH"
        
        # Install Python dependencies
        echo "Installing Python dependencies..."
        .devenv/state/venv/bin/pip install --upgrade pip
        .devenv/state/venv/bin/pip install -r requirements/local.txt
        
        if [ ! -d "teleband/media/accompaniments" ]; then
          mkdir -p teleband/media
          echo "Please add accompaniments and sample_audio folders to teleband/media/"
        fi
        
        echo "Running database migrations..."
        python manage.py migrate
        
        echo "Creating superuser..."
        python manage.py createsuperuser
        
        echo "Backend setup complete!"
      '';
    };

    backend = {
      exec = ''
        export PATH=".devenv/state/venv/bin:$PATH"
        python manage.py runserver
      '';
    };

    frontend = {
      exec = ''
        cd ../CPR-Music
        npm install
        npm run dev
      '';
    };
  };

  # Processes for devenv up
  processes = {
    django = {
      exec = ''
        export PATH=".devenv/state/venv/bin:$PATH"
        # Give postgres a moment to fully initialize
        sleep 2
        python manage.py runserver
      '';
      process-compose = {
        depends_on = {
          postgres = {
            condition = "process_healthy";
          };
        };
      };
    };
    
    frontend = {
      exec = ''
        cd ../CPR-Music
        npm install --silent
        npm run dev
      '';
    };
  };

  # disable cachix if you have trust issues
  cachix.enable = false;

  # Setup shell
  enterShell = ''
    # Fix PATH to prioritize venv
    export PATH="$PWD/.devenv/state/venv/bin:$PATH"
    
    # Create .env if doesn't exist
    if [ ! -f .env ]; then
      echo "DATABASE_URL=$DATABASE_URL" > .env
    fi
    
    # Create frontend .env.local if doesn't exist
    if [ ! -f ../CPR-Music/.env.local ]; then
      cat > ../CPR-Music/.env.local << EOF
SECRET=$SECRET
NEXTAUTH_URL=$NEXTAUTH_URL
EOF
    fi
    
    # Ensure pip packages are installed
    if ! python -c "import django" 2>/dev/null; then
      echo "Installing Python dependencies..."
      pip install --upgrade pip
      pip install -r requirements/local.txt
    fi
    
    echo "MusicCPR Development Environment Ready!"
    echo "Python: $(which python) - $(python --version)"
    echo "Pip: $(which pip)"
    echo "Node: $(node --version)"
    echo "PostgreSQL: $(postgres --version)"
    echo ""
    echo "Available commands:"
    echo "  musiccpr-init     - First time setup"
    echo "  devenv up         - Start all services"
    echo "  backend           - Start Django only"
    echo "  frontend          - Start Next.js only"
    echo ""
    echo "URLs:"
    echo "  Django admin: http://127.0.0.1:8000/admin/"
    echo "  Frontend:     http://localhost:3000"
  '';
}