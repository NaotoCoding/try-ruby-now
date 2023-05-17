require "unloosen"

class HTMLIDManager
  TRY_FIELD_ID = 'try_field'.freeze
  INPUT_TEXT_AREA_ID = 'input_text_area'.freeze
  OUTPUT_TEXT_AREA_ID = 'output_text_area'.freeze
  BUTTON_CONTAINER_ID = 'button_container'.freeze
  RUN_BUTTON_ID = 'run_button'.freeze
  RESET_BUTTON_ID = 'reset_button'.freeze
end

class TryFieldCreator
  INPUT_TEXT_AREA_PLACEHOLDER = 'Rubyのコードを入力してください'.freeze
  OUTPUT_TEXT_AREA_PLACEHOLDER = '実行値がここに表示されます'.freeze
  RUN_BUTTON_TEXT = '実行'.freeze
  RESET_BUTTON_TEXT = '削除'.freeze

  def initialize(document)
    @document = document
  end

  def add_designed_try_field_to_dom
    add_html_element_to_dom
    # try_field:拡張機能部分全体を囲むHTML要素(div)
    try_field = @document.getElementById(HTMLIDManager::TRY_FIELD_ID)
    apply_design(
      try_field,
      @document.getElementById(HTMLIDManager::INPUT_TEXT_AREA_ID),
      @document.getElementById(HTMLIDManager::OUTPUT_TEXT_AREA_ID),
      @document.getElementById(HTMLIDManager::BUTTON_CONTAINER_ID),
      @document.getElementById(HTMLIDManager::RUN_BUTTON_ID),
      @document.getElementById(HTMLIDManager::RESET_BUTTON_ID)
    )
  end

  private

    # 拡張機能で表示するHTML要素を全て作成する
    def add_html_element_to_dom
      try_field = @document.createElement("div")
      try_field.id = HTMLIDManager::TRY_FIELD_ID
      button_container = @document.createElement("div")
      button_container.id = HTMLIDManager::BUTTON_CONTAINER_ID
      # 入力用フォーム、出力用フォーム、実行ボタンを作成
      try_field.appendChild(create_text_area(HTMLIDManager::INPUT_TEXT_AREA_ID, INPUT_TEXT_AREA_PLACEHOLDER))
      try_field.appendChild(button_container)
      button_container.appendChild(create_button(HTMLIDManager::RUN_BUTTON_ID, RUN_BUTTON_TEXT))
      button_container.appendChild(create_button(HTMLIDManager::RESET_BUTTON_ID, RESET_BUTTON_TEXT))
      try_field.appendChild(create_text_area(HTMLIDManager::OUTPUT_TEXT_AREA_ID, OUTPUT_TEXT_AREA_PLACEHOLDER))
      @document.body.appendChild(try_field)
    end

    def create_text_area(html_id, placeholder)
      text_area = @document.createElement("TEXTAREA")
      text_area.id = html_id
      text_area.placeholder = placeholder
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
      apply_hover_button_design(run_button)
      apply_hover_button_design(reset_button)
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

    def apply_hover_button_design(button)
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
class TextAreaResetter
  def initialize(document)
    @document = document
  end

  def reset_text_area
    document.getElementById(HTMLIDManager::INPUT_TEXT_AREA_ID).value = ''
    document.getElementById(HTMLIDManager::OUTPUT_TEXT_AREA_ID).value = ''
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

  # 画面描画時と削除ボタンクリック時にテキストエリアを空にする
  document.getElementById(HTMLIDManager::RESET_BUTTON_ID).addEventListener("click") do
    TextAreaResetter.new(document).reset_text_area
  end

  # 実行ボタンクリック時にRubyスクリプトを実行して結果を出力する
  document.getElementById(HTMLIDManager::RUN_BUTTON_ID).addEventListener("click") do
    document.getElementById(HTMLIDManager::OUTPUT_TEXT_AREA_ID).value = RubyRunner.new(
      document.getElementById(HTMLIDManager::INPUT_TEXT_AREA_ID).value
    ).result_of_ruby_code
  end
end
