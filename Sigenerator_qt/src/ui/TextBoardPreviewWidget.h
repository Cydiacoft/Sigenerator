#pragma once

#include <QColor>
#include <QWidget>

class TextBoardPreviewWidget : public QWidget {
    Q_OBJECT
public:
    explicit TextBoardPreviewWidget(QWidget* parent = nullptr);

    void setBackgroundColor(const QColor& color);
    void setForegroundColor(const QColor& color);
    void setTitle(const QString& text);
    void setSubtitle(const QString& text);
    void setFootnote(const QString& text);

protected:
    void paintEvent(QPaintEvent* event) override;

private:
    QColor m_bg = QColor("#FFFFFF");
    QColor m_fg = QColor("#0B1120");
    QString m_title = QStringLiteral("Line 1");
    QString m_subtitle = QStringLiteral("Station");
    QString m_footnote;
};
