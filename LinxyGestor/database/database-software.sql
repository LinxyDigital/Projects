-- ------------------------------------------------------
-- SEÇÃO 1: PRODUTOS E SERVIÇOS
-- ------------------------------------------------------

-- Tabela de Categorias - Armazena as categorias de produtos e serviços, com suporte a subcategorias
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT 'Nome da categoria',
    description TEXT COMMENT 'Descrição detalhada da categoria',
    parent_category_id INT COMMENT 'ID da categoria pai (para subcategorias)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
    FOREIGN KEY (parent_category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX (parent_category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Produtos - Armazena todos os produtos da loja, tanto físicos quanto digitais
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT 'Nome do produto',
    description TEXT COMMENT 'Descrição detalhada do produto',
    sale_price DECIMAL(10,2) NOT NULL COMMENT 'Valor de venda do produto',
    promo_price DECIMAL(10,2) COMMENT 'Preço promocional (quando em promoção)',
    cost_price DECIMAL(10,2) COMMENT 'Valor de custo/produção do produto',
    has_shipping BOOLEAN DEFAULT FALSE COMMENT 'Indica se o produto tem frete',
    shipping_cost DECIMAL(10,2) COMMENT 'Custo do frete do produto',
    quantity INT DEFAULT 0 COMMENT 'Quantidade em estoque',
    status ENUM('hidden', 'visible') DEFAULT 'hidden' COMMENT 'Status: oculto ou visível na loja',
    category_id INT COMMENT 'ID da categoria do produto',
    product_type ENUM('physical', 'digital') NOT NULL COMMENT 'Tipo do produto: físico ou digital',
    requires_national_id BOOLEAN DEFAULT FALSE COMMENT 'Requer CPF/CNPJ para compra',
    barcode VARCHAR(50) COMMENT 'Código de barras do produto',
    sku VARCHAR(50) COMMENT 'Código de estoque (SKU)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de cadastro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_product_type (product_type),
    INDEX idx_sku (sku)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Imagens de Produto - Armazena os caminhos das imagens otimizadas associadas aos produtos
CREATE TABLE IF NOT EXISTS product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL COMMENT 'ID do produto associado',
    image_path VARCHAR(255) NOT NULL COMMENT 'Caminho relativo da imagem otimizada no storage público',
    original_filename VARCHAR(255) COMMENT 'Nome original do arquivo enviado pelo usuário',
    alt_text VARCHAR(255) COMMENT 'Texto alternativo para acessibilidade',
    width INT COMMENT 'Largura da imagem em pixels após otimização',
    height INT COMMENT 'Altura da imagem em pixels após otimização',
    file_size INT COMMENT 'Tamanho do arquivo em bytes após otimização',
    format VARCHAR(10) DEFAULT 'webp' COMMENT 'Formato da imagem (preferencialmente webp)',
    is_main BOOLEAN DEFAULT FALSE COMMENT 'Indica se é a imagem principal do produto',
    display_order INT DEFAULT 0 COMMENT 'Ordem de exibição da imagem',
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de upload da imagem',
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX (product_id),
    INDEX (is_main)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Serviços - Armazena todos os serviços oferecidos pela empresa
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT 'Nome do serviço',
    description TEXT COMMENT 'Descrição detalhada do serviço',
    price DECIMAL(10,2) NOT NULL COMMENT 'Valor do serviço',
    promo_price DECIMAL(10,2) COMMENT 'Preço promocional (quando aplicável)',
    operational_cost DECIMAL(10,2) COMMENT 'Custo operacional do serviço',
    has_scheduling BOOLEAN DEFAULT FALSE COMMENT 'Indica se o serviço requer agendamento',
    duration_minutes INT COMMENT 'Duração do serviço em minutos',
    status ENUM('hidden', 'visible') DEFAULT 'hidden' COMMENT 'Status: oculto ou visível na loja',
    category_id INT COMMENT 'ID da categoria do serviço',
    service_type ENUM('in_person', 'online') NOT NULL COMMENT 'Tipo de serviço: presencial ou online',
    identification_code VARCHAR(50) COMMENT 'Código de identificação do serviço',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de cadastro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_service_type (service_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Imagens de Serviço - Armazena os caminhos das imagens otimizadas associadas aos serviços
CREATE TABLE IF NOT EXISTS service_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL COMMENT 'ID do serviço associado',
    image_path VARCHAR(255) NOT NULL COMMENT 'Caminho relativo da imagem otimizada no storage público',
    original_filename VARCHAR(255) COMMENT 'Nome original do arquivo enviado pelo usuário',
    alt_text VARCHAR(255) COMMENT 'Texto alternativo para acessibilidade',
    width INT COMMENT 'Largura da imagem em pixels após otimização',
    height INT COMMENT 'Altura da imagem em pixels após otimização',
    file_size INT COMMENT 'Tamanho do arquivo em bytes após otimização',
    format VARCHAR(10) DEFAULT 'webp' COMMENT 'Formato da imagem (preferencialmente webp)',
    is_main BOOLEAN DEFAULT FALSE COMMENT 'Indica se é a imagem principal',
    display_order INT DEFAULT 0 COMMENT 'Ordem de exibição da imagem',
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de upload da imagem',
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX (service_id),
    INDEX (is_main)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Disponibilidade de Serviço - Armazena os horários disponíveis para cada serviço
CREATE TABLE IF NOT EXISTS service_availability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL COMMENT 'ID do serviço',
    weekday TINYINT NOT NULL COMMENT '0-6 (domingo-sábado)',
    start_time TIME NOT NULL COMMENT 'Hora de início da disponibilidade',
    end_time TIME NOT NULL COMMENT 'Hora de fim da disponibilidade',
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX (service_id, weekday)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- SEÇÃO 2: CLIENTES
-- ------------------------------------------------------

-- Tabela de Clientes - Armazena os dados de todos os clientes da loja
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT 'Nome completo do cliente',
    email VARCHAR(255) NOT NULL COMMENT 'Email do cliente (usado para login)',
    password VARCHAR(255) NOT NULL COMMENT 'Senha do cliente (criptografada)',
    phone VARCHAR(20) COMMENT 'Número de telefone do cliente',
    tax_id VARCHAR(20) COMMENT 'CPF ou CNPJ do cliente',
    status ENUM('active', 'inactive') DEFAULT 'active' COMMENT 'Status: ativo ou inativo',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de cadastro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
    UNIQUE INDEX idx_email (email),
    INDEX idx_tax_id (tax_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Endereços do Cliente - Armazena os múltiplos endereços de cada cliente
CREATE TABLE IF NOT EXISTS customer_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL COMMENT 'ID do cliente',
    address_type VARCHAR(20) COMMENT 'Tipo do endereço: residencial, comercial, etc.',
    postal_code VARCHAR(10) NOT NULL COMMENT 'CEP',
    street VARCHAR(255) NOT NULL COMMENT 'Nome da rua/logradouro',
    number VARCHAR(20) NOT NULL COMMENT 'Número do endereço',
    complement VARCHAR(100) COMMENT 'Complemento do endereço',
    neighborhood VARCHAR(100) NOT NULL COMMENT 'Bairro',
    city VARCHAR(100) NOT NULL COMMENT 'Cidade',
    state VARCHAR(2) NOT NULL COMMENT 'Estado (UF)',
    is_main BOOLEAN DEFAULT FALSE COMMENT 'Indica se é o endereço principal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de cadastro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX (customer_id),
    INDEX (postal_code),
    INDEX (is_main)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Usuários Administradores - Armazena os dados dos administradores do sistema
CREATE TABLE IF NOT EXISTS administrators (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT 'Nome do administrador',
    email VARCHAR(255) NOT NULL COMMENT 'Email do administrador (usado para login)',
    password VARCHAR(255) NOT NULL COMMENT 'Senha do administrador (criptografada)',
    access_level ENUM('admin', 'manager', 'seller') DEFAULT 'seller' COMMENT 'Nível de acesso: admin, gerente ou vendedor',
    status ENUM('active', 'inactive') DEFAULT 'active' COMMENT 'Status: ativo ou inativo',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de cadastro',
    last_access TIMESTAMP NULL COMMENT 'Data do último acesso ao sistema',
    UNIQUE INDEX idx_email (email),
    INDEX idx_access_level (access_level),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- SEÇÃO 3: PERSONALIZAÇÃO DA LOJA
-- ------------------------------------------------------

-- Tabela de Configurações da Loja - Armazena todas as configurações personalizáveis da loja
CREATE TABLE IF NOT EXISTS store_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL COMMENT 'Nome da loja',
    logo_url VARCHAR(255) COMMENT 'URL da logo da loja',
    main_color VARCHAR(20) COMMENT 'Cor principal da loja (formato hexadecimal: #RRGGBB)',
    secondary_color VARCHAR(20) COMMENT 'Cor secundária da loja (formato hexadecimal: #RRGGBB)',
    text_color VARCHAR(20) COMMENT 'Cor do texto da loja (formato hexadecimal: #RRGGBB)',
    border_color VARCHAR(20) COMMENT 'Cor das bordas (formato hexadecimal: #RRGGBB)',
    whatsapp VARCHAR(20) COMMENT 'Número do WhatsApp da loja',
    contact_email VARCHAR(255) COMMENT 'Email de contato',
    contact_phone VARCHAR(20) COMMENT 'Telefone de contato',
    meta_description TEXT COMMENT 'Meta descrição para SEO',
    meta_keywords TEXT COMMENT 'Meta palavras-chave para SEO',
    facebook_url VARCHAR(255) COMMENT 'URL da página do Facebook',
    instagram_url VARCHAR(255) COMMENT 'URL da página do Instagram',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Produtos em Destaque - Armazena os produtos destacados na loja em diferentes seções
CREATE TABLE IF NOT EXISTS featured_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL COMMENT 'ID do produto em destaque',
    display_order INT DEFAULT 0 COMMENT 'Ordem de exibição',
    section ENUM('new_arrivals', 'promotions', 'best_sellers') DEFAULT 'new_arrivals' COMMENT 'Seção: novidades, promoções ou mais vendidos',
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de início do destaque',
    end_date TIMESTAMP NULL COMMENT 'Data de fim do destaque',
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX (product_id),
    INDEX (section),
    INDEX (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Serviços em Destaque - Armazena os serviços destacados na loja em diferentes seções
CREATE TABLE IF NOT EXISTS featured_services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL COMMENT 'ID do serviço em destaque',
    display_order INT DEFAULT 0 COMMENT 'Ordem de exibição',
    section ENUM('new_arrivals', 'promotions', 'trending') DEFAULT 'new_arrivals' COMMENT 'Seção: novidades, promoções ou em alta',
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de início do destaque',
    end_date TIMESTAMP NULL COMMENT 'Data de fim do destaque',
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX (service_id),
    INDEX (section),
    INDEX (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- SEÇÃO 4: PEDIDOS E CARRINHO
-- ------------------------------------------------------

-- Tabela de Carrinhos - Armazena os carrinhos de compra dos clientes
CREATE TABLE IF NOT EXISTS carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT COMMENT 'ID do cliente (NULL para carrinhos de visitantes)',
    session_id VARCHAR(100) COMMENT 'ID da sessão para carrinho de visitantes não logados',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação do carrinho',
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última modificação',
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX (customer_id),
    INDEX (session_id),
    INDEX (last_modified)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Itens do Carrinho (Produtos) - Armazena os produtos adicionados aos carrinhos
CREATE TABLE IF NOT EXISTS cart_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL COMMENT 'ID do carrinho',
    product_id INT NOT NULL COMMENT 'ID do produto',
    quantity INT NOT NULL DEFAULT 1 COMMENT 'Quantidade do produto',
    unit_price DECIMAL(10,2) NOT NULL COMMENT 'Valor unitário do produto',
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de adição ao carrinho',
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX (cart_id),
    INDEX (product_id),
    INDEX (added_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Itens do Carrinho (Serviços) - Armazena os serviços adicionados aos carrinhos
CREATE TABLE IF NOT EXISTS cart_services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL COMMENT 'ID do carrinho',
    service_id INT NOT NULL COMMENT 'ID do serviço',
    scheduled_date DATETIME COMMENT 'Data e hora agendadas para o serviço',
    unit_price DECIMAL(10,2) NOT NULL COMMENT 'Valor unitário do serviço',
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de adição ao carrinho',
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX (cart_id),
    INDEX (service_id),
    INDEX (scheduled_date),
    INDEX (added_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Pedidos - Armazena todos os pedidos feitos pelos clientes
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL COMMENT 'ID do cliente que fez o pedido',
    delivery_address_id INT COMMENT 'ID do endereço de entrega',
    products_total DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'Valor total dos produtos',
    services_total DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'Valor total dos serviços',
    shipping_cost DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'Valor do frete',
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'Valor do desconto aplicado',
    total_amount DECIMAL(10,2) NOT NULL COMMENT 'Valor total do pedido',
    payment_method ENUM('pix', 'delivery') NOT NULL COMMENT 'Método de pagamento: pix ou na entrega',
    payment_status ENUM('pending', 'paid', 'cancelled') DEFAULT 'pending' COMMENT 'Status do pagamento: aguardando, pago ou cancelado',
    order_status ENUM('pending', 'preparing', 'ready', 'shipping', 'completed', 'cancelled') DEFAULT 'pending' COMMENT 'Status do pedido: pendente, preparando, pronto, enviando, finalizado ou cancelado',
    tracking_code VARCHAR(50) COMMENT 'Código de rastreamento da entrega',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação do pedido',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
    FOREIGN KEY (delivery_address_id) REFERENCES customer_addresses(id) ON DELETE SET NULL,
    INDEX (customer_id),
    INDEX (delivery_address_id),
    INDEX (payment_status),
    INDEX (order_status),
    INDEX (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Itens do Pedido (Produtos) - Armazena os produtos incluídos em cada pedido
CREATE TABLE IF NOT EXISTS order_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL COMMENT 'ID do pedido',
    product_id INT NOT NULL COMMENT 'ID do produto',
    quantity INT NOT NULL DEFAULT 1 COMMENT 'Quantidade do produto',
    unit_price DECIMAL(10,2) NOT NULL COMMENT 'Valor unitário do produto',
    total_price DECIMAL(10,2) NOT NULL COMMENT 'Valor total deste item',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    INDEX (order_id),
    INDEX (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Itens do Pedido (Serviços) - Armazena os serviços incluídos em cada pedido
CREATE TABLE IF NOT EXISTS order_services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL COMMENT 'ID do pedido',
    service_id INT NOT NULL COMMENT 'ID do serviço',
    scheduled_date DATETIME COMMENT 'Data e hora agendadas para o serviço',
    price DECIMAL(10,2) NOT NULL COMMENT 'Valor do serviço',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT,
    INDEX (order_id),
    INDEX (service_id),
    INDEX (scheduled_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Pagamentos - Armazena os detalhes de pagamento de cada pedido
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL COMMENT 'ID do pedido relacionado',
    payment_method ENUM('pix', 'delivery') NOT NULL COMMENT 'Método de pagamento: pix ou na entrega',
    status ENUM('pending', 'confirmed', 'cancelled', 'refunded') DEFAULT 'pending' COMMENT 'Status: pendente, confirmado, cancelado ou estornado',
    amount DECIMAL(10,2) NOT NULL COMMENT 'Valor do pagamento',
    transaction_code VARCHAR(100) COMMENT 'Código da transação de pagamento',
    pix_qrcode TEXT COMMENT 'QR Code para pagamento PIX',
    pix_copy_paste_key TEXT COMMENT 'Chave PIX copia e cola',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação do pagamento',
    confirmed_at TIMESTAMP NULL COMMENT 'Data de confirmação do pagamento',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX (order_id),
    INDEX (status),
    INDEX (payment_method)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Histórico de Status do Pedido - Armazena o histórico de alterações de status dos pedidos
CREATE TABLE IF NOT EXISTS order_status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL COMMENT 'ID do pedido',
    previous_status ENUM('pending', 'preparing', 'ready', 'shipping', 'completed', 'cancelled') COMMENT 'Status anterior do pedido',
    new_status ENUM('pending', 'preparing', 'ready', 'shipping', 'completed', 'cancelled') NOT NULL COMMENT 'Novo status do pedido',
    comment TEXT COMMENT 'Comentário sobre a mudança de status',
    admin_id INT COMMENT 'ID do administrador que alterou o status',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data da alteração de status',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES administrators(id) ON DELETE SET NULL,
    INDEX (order_id),
    INDEX (admin_id),
    INDEX (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Comprovantes - Armazena os comprovantes gerados para os pedidos
CREATE TABLE IF NOT EXISTS receipts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL COMMENT 'ID do pedido relacionado',
    receipt_type ENUM('voucher', 'invoice', 'receipt') NOT NULL COMMENT 'Tipo: voucher, nota fiscal ou boleto',
    file_path VARCHAR(255) NOT NULL COMMENT 'Caminho do arquivo do comprovante',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de geração do comprovante',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX (order_id),
    INDEX (receipt_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

