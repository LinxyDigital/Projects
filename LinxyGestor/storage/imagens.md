### Passo 1: Estrutura do Banco de Dados (MariaDB)

Primeiro, defina a tabela que armazenará a referência da imagem. Supondo que você tenha uma tabela de `products`, adicione uma coluna para guardar o caminho do arquivo.

**Exemplo de tabela `products` em SQL:**

```sql
CREATE TABLE `products` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `image_path` VARCHAR(255) NULL, -- Coluna para guardar o caminho da imagem
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Ponto-chave:** A coluna `image_path` é um `VARCHAR`, leve e eficiente. Ela armazenará apenas o caminho relativo do arquivo dentro do disco `public` do Laravel (ex: `products/imagem_unica_12345.webp`).

### Passo 2: Instalação da Dependência

Como sugerido no guia, a biblioteca `Intervention/Image` é fundamental para otimização.

```bash
composer require intervention/image
```

### Passo 3: O Model com Limpeza Automática

Edite seu model Eloquent (ex: `app/Models/Product.php`) para incluir o evento `deleted`, que apagará o arquivo físico quando o registro do banco for excluído.

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Product extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description', 'image_path'];

    /**
     * O método "booted" do modelo.
     * Registra o evento para apagar a imagem ao deletar o produto.
     */
    protected static function booted(): void
    {
        static::deleted(function (Product $product) {
            // Garante que só tenta apagar se houver um caminho de imagem.
            if ($product->image_path) {
                Storage::disk('public')->delete($product->image_path);
            }
        });
    }
}
```

### Passo 4: O Controller para Upload e Otimização

Este é o cérebro da operação. O controller validará, otimizará e salvará a imagem.

`app/Http/Controllers/ProductController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Facades\Image; // Importe o Facade correto

class ProductController extends Controller
{
    /**
     * Salva um novo produto com uma imagem otimizada.
     */
    public function store(Request $request)
    {
        // 1. Validação rigorosa, conforme o guia
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'product_image' => [ // Usando um nome de campo claro
                'required',
                'image',
                'mimes:jpeg,png,jpg,gif', // Aceita os formatos mais comuns para conversão
                'max:2048', // Limite de 2MB
                'dimensions:min_width=100,min_height=100'
            ],
        ]);

        $imageFile = $request->file('product_image');

        // 2. Otimização em tempo real
        $image = Image::make($imageFile)
            ->resize(1200, null, function ($constraint) { // Redimensiona para no máximo 1200px de largura
                $constraint->aspectRatio();
                $constraint->upsize(); // Evita que imagens pequenas sejam ampliadas
            })
            ->encode('webp', 80); // Converte para WebP com 80% de qualidade

        // 3. Salvando o arquivo
        $imageName = uniqid('product_') . '_' . time() . '.webp';
        $path = 'products/' . $imageName; // Salva em um subdiretório para organização
        
        Storage::disk('public')->put($path, $image);

        // 4. Salvando o caminho no banco de dados
        $product = Product::create([
            'name' => $validated['name'],
            'description' => $validated['description'],
            'image_path' => $path,
        ]);

        return redirect()->route('products.show', $product)->with('success', 'Produto criado com sucesso!');
    }
}

```

### Passo 5: As Rotas

Defina as rotas em `routes/web.php` para exibir o formulário, processar o upload e, crucialmente, a rota temporária para criar o link simbólico na Hostinger.

`routes/web.php`:

```php
<?php

use App\Http\Controllers\ProductController;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Route;

// Rota para exibir o formulário de criação
Route::get('products/create', function() {
    return view('products.create');
})->name('products.create');

// Rota para processar o formulário
Route::post('products', [ProductController::class, 'store'])->name('products.store');

// Rota para exibir o produto (e sua imagem)
Route::get('products/{product}', function(App\Models\Product $product) {
    return view('products.show', ['product' => $product]);
})->name('products.show');


// --- ROTA TEMPORÁRIA PARA HOSTINGER ---
// CUIDADO: USE E REMOVA IMEDIATAMENTE APÓS O DEPLOY!
Route::get('/create-storage-link', function () {
    try {
        Artisan::call('storage:link');
        return 'Link simbólico criado com sucesso!';
    } catch (\Exception $e) {
        return 'Erro ao criar o link simbólico: ' . $e->getMessage();
    }
});
```

### Passo 6: As Views (Blade)

**Formulário de Upload (`resources/views/products/create.blade.php`):**

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Criar Produto</title>
</head>
<body>
    <h1>Novo Produto</h1>

    @if ($errors->any())
        <div style="color: red;">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('products.store') }}" method="POST" enctype="multipart/form-data">
        @csrf
        <div>
            <label for="name">Nome do Produto:</label>
            <input type="text" id="name" name="name" required>
        </div>
        <br>
        <div>
            <label for="product_image">Imagem do Produto:</label>
            <input type="file" id="product_image" name="product_image" required>
        </div>
        <br>
        <button type="submit">Salvar Produto</button>
    </form>
</body>
</html>
```

**View de Exibição (`resources/views/products/show.blade.php`):**

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>{{ $product->name }}</title>
</head>
<body>
    <h1>{{ $product->name }}</h1>

    @if (session('success'))
        <div style="color: green;">{{ session('success') }}</div>
    @endif

    @if($product->image_path)
        <p>
            <img 
                src="{{ asset('storage/' . $product->image_path) }}" 
                alt="Imagem de {{ $product->name }}" 
                style="max-width: 600px; height: auto;"
            >
        </p>
        <p>Caminho do arquivo: {{ $product->image_path }}</p>
    @else
        <p>Este produto não possui imagem.</p>
    @endif

    <form action="{{ route('products.destroy', $product) }}" method="POST" onsubmit="return confirm('Tem certeza?');">
        @csrf
        @method('DELETE')
        <button type="submit" style="color: red;">Deletar Produto</button>
    </form>

</body>
</html>
```

*(Nota: Para o formulário de deleção funcionar, você precisará adicionar a rota `Route::delete('products/{product}', ...)` em seu arquivo de rotas).*

### Resumo da Implantação na Hostinger

1.  **Deploy:** Envie seus arquivos, colocando o conteúdo da pasta `public` do seu projeto Laravel dentro da `public_html` da Hostinger.
2.  **Ajuste o `index.php`:** Edite o `public_html/index.php` para corrigir os caminhos para `../vendor/autoload.php` e `../bootstrap/app.php`.
3.  **Crie o Link:** Acesse `seudominio.com.br/create-storage-link` uma única vez no navegador. Verifique se uma pasta `storage` apareceu dentro da sua `public_html`.
4.  **REMOVA A ROTA:** **Comente ou apague imediatamente a rota `/create-storage-link`** do seu arquivo `routes/web.php` e faça o deploy novamente.
5.  **Teste:** Faça o upload de uma imagem, verifique se ela aparece e se o arquivo otimizado (`.webp`) foi salvo em `storage/app/public/products`. Depois, exclua o registro e confirme que o arquivo físico também foi removido do servidor.