# -- Горячая клавиша: Shift + Cmd + Space
hs.hotkey.bind({"shift", "cmd"}, "space", function()
    local screenshotPath = os.getenv("HOME") .. "/Desktop/screenshot.png"
    local promptText = [[
На изображении показано окно браузера с технической задачей (это может быть код, текст задания, описание алгоритма, баг или требование к рефакторингу). Выполни следующие шаги:

1. Извлечение содержимого:
- Выдели и перепиши только полезную часть — код или текст задания.
- Не включай элементы интерфейса (вкладки, адресную строку, боковые панели, кнопки и т.д.).

2. Определи тип задачи и выполни соответствующее действие:
- Алгоритм: реши задачу на языке Swift, добавь подробные комментарии на русском к каждому шагу. Обязательно укажи временную и пространственную сложность.
- Рефакторинг: перепиши код с улучшениями (не забудь разделить на методы, улучшай читаемость и структуру). Поясни в комментариях, что изменено и почему это лучше.
- Поиск и исправление ошибок: найди и исправь ошибки. Добавь комментарии, что было не так и как исправлено.

3. Комментарии пиши прямо в коде на русском языке.

4. Резюме после кода:
- Опиши кратко, что сделано.
- Какие улучшения внесены.
- С какими трудностями столкнулся.
- (Если алгоритм) — оцени временную и пространственную сложность.

Формат комментариев:
func example() {
    // Эта функция делает X, потому что...
}
]]

    local captureCmd = string.format('screencapture -w %q', screenshotPath)
    local success, _, _, rc = hs.execute(captureCmd, true)

    if not success or rc ~= 0 then
        return
    end

    local app = hs.application.find("ChatGPT")
    if not app then
        hs.application.launchOrFocus("ChatGPT")
        hs.timer.usleep(3000000)  
    end

    local openCmd = string.format('open -a ChatGPT %q', screenshotPath)
    hs.execute(openCmd, true)

    hs.timer.doAfter(0.0, function()
        local originalClipboard = hs.pasteboard.getContents() or ""

        hs.pasteboard.clearContents()
        hs.eventtap.keyStroke({"cmd"}, "a")
        hs.timer.usleep(200000)
        hs.eventtap.keyStroke({"cmd"}, "c")
        hs.timer.usleep(200000)

        local fieldContent = hs.pasteboard.getContents() or ""

        if fieldContent:match("^%s*$") then
		hs.pasteboard.setContents(promptText)
		hs.eventtap.keyStroke({"cmd"}, "v")
        end

        hs.timer.doAfter(0.3, function()
            hs.pasteboard.setContents(originalClipboard)
        end)
    end)
end)
