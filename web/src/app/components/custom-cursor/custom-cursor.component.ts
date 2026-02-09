import { Component, HostListener, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-custom-cursor',
    standalone: true,
    imports: [CommonModule],
    template: `
    <div class="cursor" 
         [style.left.px]="cursorX()" 
         [style.top.px]="cursorY()"
         [class.cursor-hover]="isHovering()">
      <div class="cursor-dot"></div>
      <div class="cursor-outline"></div>
    </div>
  `,
    styles: [`
    .cursor {
      position: fixed;
      pointer-events: none;
      z-index: 9999;
      mix-blend-mode: exclusion;
      transition: transform 0.15s ease-out;
    }

    .cursor-dot {
      position: absolute;
      width: 8px;
      height: 8px;
      background: white;
      border-radius: 50%;
      transform: translate(-50%, -50%);
      transition: width 0.3s ease, height 0.3s ease;
    }

    .cursor-outline {
      position: absolute;
      width: 40px;
      height: 40px;
      border: 1.5px solid rgba(255, 255, 255, 0.8);
      border-radius: 50%;
      transform: translate(-50%, -50%);
      transition: width 0.3s ease, height 0.3s ease, opacity 0.3s ease, background-color 0.3s;
    }

    .cursor-hover .cursor-dot {
      width: 0;
      height: 0;
    }

    .cursor-hover .cursor-outline {
      width: 60px;
      height: 60px;
      background-color: rgba(255, 255, 255, 0.1);
      border-color: transparent;
    }

    /* Hide default cursor */
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
      
      :host ::ng-deep body,
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
        const isInteractive = target.matches('button, a, input, [role="button"]') ||
            target.closest('button, a, input, [role="button"]');
        this.isHovering.set(!!isInteractive);
    }
}
