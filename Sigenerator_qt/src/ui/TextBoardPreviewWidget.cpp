#include "TextBoardPreviewWidget.h"

#include <QPainter>

TextBoardPreviewWidget::TextBoardPreviewWidget(QWidget* parent)
    : QWidget(parent)
{
    setMinimumSize(900, 620);
}

void TextBoardPreviewWidget::setBackgroundColor(const QColor& color)
{
    m_bg = color;
    update();
}

void TextBoardPreviewWidget::setForegroundColor(const QColor& color)
{
    m_fg = color;
    update();
}

void TextBoardPreviewWidget::setTitle(const QString& text)
{
    m_title = text;
    update();
}

void TextBoardPreviewWidget::setSubtitle(const QString& text)
{
    m_subtitle = text;
    update();
}

void TextBoardPreviewWidget::setFootnote(const QString& text)
{
    m_footnote = text;
    update();
}

void TextBoardPreviewWidget::paintEvent(QPaintEvent*)
{
    QPainter p(this);
    p.fillRect(rect(), QColor("#0F172A"));

    const qreal margin = 48.0;
    const QRectF boardRect = rect().adjusted(margin, margin, -margin, -margin);

    p.setRenderHint(QPainter::Antialiasing, true);
    p.fillRect(boardRect, m_bg);
    p.setPen(QPen(m_fg, 2));
    p.drawRect(boardRect);

    QFont titleFont = p.font();
    titleFont.setPointSize(40);
    titleFont.setBold(true);
    p.setFont(titleFont);
    p.setPen(m_fg);
    p.drawText(boardRect.adjusted(36, 40, -36, -40), Qt::AlignTop | Qt::AlignHCenter, m_title);

    QFont subFont = p.font();
    subFont.setPointSize(28);
    subFont.setBold(false);
    p.setFont(subFont);
    p.drawText(boardRect.adjusted(36, 160, -36, -160), Qt::AlignVCenter | Qt::AlignHCenter, m_subtitle);

    if (!m_footnote.trimmed().isEmpty()) {
        QFont footFont = p.font();
        footFont.setPointSize(16);
        p.setFont(footFont);
        p.drawText(boardRect.adjusted(28, 28, -28, -28), Qt::AlignBottom | Qt::AlignRight, m_footnote);
    }
}
