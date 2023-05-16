require "unloosen"

class TryFieldCreator
  def initialize(document)
    @document = document
  end

  def add_designed_try_field_to_dom
    prepare_element
    try_field = @document.getElementById("try_field")
    run_button = @document.getElementById("run_button")
    reset_button = @document.getElementById("reset_button")
    apply_design(
      try_field,
      @document.getElementById("input_text_area"),
      @document.getElementById("output_text_area"),
      @document.getElementById("button_container"),
      run_button,
      reset_button
    )
    hover_button(run_button)
    hover_button(reset_button)
    try_field
  end

  private

    # 拡張機能で表示するHTML要素を全て作成する
    def prepare_element
      try_field = @document.createElement("div")
      try_field.id = "try_field"
      button_container = @document.createElement("div")
      button_container.id = "button_container"
      # 入力用フォーム、出力用フォーム、実行ボタンを作成
      try_field.appendChild(create_text_area("input_text_area"))
      try_field.appendChild(button_container)
      button_container.appendChild(create_button('run_button', '実行'))
      button_container.appendChild(create_button('reset_button', '削除'))
      try_field.appendChild(create_text_area("output_text_area"))
      @document.body.appendChild(try_field)
    end

    def create_text_area(html_id)
      text_area = @document.createElement("TEXTAREA")
      text_area.id = html_id
      text_area
    end

    def create_button(html_id, text)
      run_button = @document.createElement("button")
      run_button.id = html_id
      run_button.textContent = text
      run_button
    end

    # 拡張機能部分の全てのデザインを適用する
    def apply_design(try_field, input_text_area, output_text_area, button_container, run_button, reset_button)
      apply_try_field_design(try_field)
      apply_text_area_design(input_text_area)
      apply_text_area_design(output_text_area)
      apply_button_container_design(button_container)
      apply_run_button_design(run_button)
      apply_reset_button_design(reset_button)
      try_field
    end

    def apply_try_field_design(try_field)
      try_field_style = try_field.style
      try_field_style.position = 'fixed'
      try_field_style.bottom = '0'
      try_field_style.left = '0'
      try_field_style.width = '100%'
      try_field_style.height = '35%'
      try_field_style.paddingTop = '1%'
      try_field_style.backgroundColor = 'rgba(0, 0, 0, 0.4)'
      try_field_style.zIndex = '10000'
      try_field_style.display = 'flex'
      try_field_style.justifyContent = 'space-around'
      try_field_style.alignItems = 'center'
    end

    def apply_text_area_design(text_area)
      text_area_style = text_area.style
      text_area_style.width = '30%'
      text_area_style.height = '60%'
      text_area_style.fontSize = '1.5rem'
    end

    def apply_button_container_design(button_container)
      button_container_style = button_container.style
      button_container_style.display = 'flex'
      button_container_style.flexDirection = 'column'
      button_container_style.justifyContent = 'center'
    end

    def apply_run_button_design(run_button)
      run_button_style = run_button.style
      run_button_style.backgroundColor = '#CC342D'
      run_button_style.border = 'none'
      run_button_style.color = 'White'
      run_button_style.fontSize = '1.2rem'
      run_button_style.padding = '1rem 1.5rem'
      run_button_style.transitionDuration = '0.4s'
      run_button_style.cursor = 'pointer'
      run_button_style.borderRadius = '12px'
      run_button_style.marginBottom = '30px'
    end

    def apply_reset_button_design(reset_button)
      reset_button_style = reset_button.style
      reset_button_style.backgroundColor = '#CC342D'
      reset_button_style.border = 'none'
      reset_button_style.color = 'White'
      reset_button_style.fontSize = '1.2rem'
      reset_button_style.padding = '1rem 1.5rem'
      reset_button_style.transitionDuration = '0.4s'
      reset_button_style.cursor = 'pointer'
      reset_button_style.borderRadius = '12px'
    end

    def hover_button(button)
      button_style = button.style
      button.addEventListener('mouseover') do
        button_style.backgroundColor = 'White'
        button_style.color = '#CC342D'
      end

      button.addEventListener('mouseout') do
        button_style.backgroundColor = '#CC342D'
        button_style.color = 'White'
      end
    end
end

# テキストエリアの初期化を管理
class TextAreaInitializer
  INITIAL_INPUT_TEXT = 'Rubyのコードを入力してください'
  INITIAL_OUTPUT_TEXT = '実行値がここに表示されます'

  def initialize(document)
    @document = document
    @input_text_area = @document.getElementById("input_text_area")
    @output_text_area = @document.getElementById("output_text_area")
  end

  def reset_text_area
    @document.getElementById("input_text_area").value = ''
    @document.getElementById("output_text_area").value = ''
  end

  def set_placeholder
    @document.getElementById("input_text_area").placeholder = INITIAL_INPUT_TEXT
    @document.getElementById("output_text_area").placeholder = INITIAL_OUTPUT_TEXT
  end
end

# Rubyのコード実行を管理
class RubyRunner
  def initialize(script)
    @script = script
  end

  def result_of_ruby_code
    begin
      eval(@script).to_s
    rescue => e
      e.message
    end
  end
end

# Main code
content_script site: "https://docs.ruby-lang.org/" do
  TryFieldCreator.new(document).add_designed_try_field_to_dom

  # 画面描画時と削除ボタンクリック時にテキストエリアを初期化する
  TextAreaInitializer.new(document).set_placeholder
  reset_button = document.getElementById("reset_button")
  reset_button.addEventListener("click") do
    TextAreaInitializer.new(document).reset_text_area
  end

  # 実行ボタンクリック時にRubyスクリプトを実行して結果を出力する
  run_button = document.getElementById("run_button")
  input_text_area = document.getElementById("input_text_area")
  output_text_area = document.getElementById("output_text_area")
  run_button.addEventListener("click") do
    output_text_area.value = RubyRunner.new(input_text_area.value).result_of_ruby_code
  end
end
