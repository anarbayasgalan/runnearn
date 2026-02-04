import { Component, HostListener, Inject, PLATFORM_ID, ElementRef, Renderer2 } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { isPlatformBrowser } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'runnearn-web';

  constructor(
    @Inject(PLATFORM_ID) private platformId: Object,
    private el: ElementRef,
    private renderer: Renderer2
  ) { }

  @HostListener('document:mousemove', ['$event'])
  onMouseMove(event: MouseEvent) {
    if (isPlatformBrowser(this.platformId)) {
      const x = event.clientX;
      const y = event.clientY;

      this.el.nativeElement.style.setProperty('--mouse-x', `${x}px`);
      this.el.nativeElement.style.setProperty('--mouse-y', `${y}px`);
    }
  }
}
