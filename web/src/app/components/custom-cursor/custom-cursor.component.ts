import { Component, HostListener, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-custom-cursor',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="cursor" 
         [style.transform]="'translate3d(' + cursorX() + 'px, ' + cursorY() + 'px, 0)'"
         [class.cursor-hover]="isHovering()">
      <div class="cursor-dot"></div>
      <div class="cursor-outline"></div>
    </div>
  `,
  styles: [`
    .cursor {
      position: fixed;
      top: 0;
      left: 0;
      width: 0;
      height: 0;
      pointer-events: none;
      z-index: 2147483647;
    }

    .cursor-dot {
      position: absolute;
      top: 0;
      left: 0;
      width: 8px;
      height: 8px;
      background: #FF6B00; /* Primary Orange */
      border-radius: 50%;
      transform: translate(-50%, -50%);
      transition: width 0.3s ease, height 0.3s ease;
      box-shadow: 0 0 10px rgba(255, 107, 0, 0.5);
    }

    .cursor-outline {
      position: absolute;
      top: 0;
      left: 0;
      width: 40px;
      height: 40px;
      border: 2px solid #FF6B00;
      border-radius: 50%;
      transform: translate(-50%, -50%);
      transition: width 0.3s ease, height 0.3s ease, opacity 0.3s ease, background-color 0.3s;
      opacity: 0.6;
    }

    .cursor-hover .cursor-dot {
      width: 4px;
      height: 4px;
    }

    .cursor-hover .cursor-outline {
      width: 60px;
      height: 60px;
      background-color: rgba(255, 107, 0, 0.1);
      border-color: transparent;
    }

    /* Global Cursor Hiding */
    :host ::ng-deep body,
    :host ::ng-deep button,
    :host ::ng-deep a,
    :host ::ng-deep input,
    :host ::ng-deep * {
      cursor: none !important;
    }

    @media (max-width: 768px) {
      .cursor {
        display: none;
      }
      
      :host ::ng-deep * {
        cursor: auto !important;
      }
    }
  `]
})
export class CustomCursorComponent {
  cursorX = signal(0);
  cursorY = signal(0);
  isHovering = signal(false);

  @HostListener('document:mousemove', ['$event'])
  onMouseMove(event: MouseEvent) {
    requestAnimationFrame(() => {
      this.cursorX.set(event.clientX);
      this.cursorY.set(event.clientY);
    });
  }

  @HostListener('document:mouseover', ['$event'])
  onMouseOver(event: MouseEvent) {
    const target = event.target as HTMLElement;
    const isInteractive = target.matches('button, a, input, [role="button"], .btn') ||
      !!target.closest('button, a, input, [role="button"], .btn');
    this.isHovering.set(isInteractive);
  }
}
