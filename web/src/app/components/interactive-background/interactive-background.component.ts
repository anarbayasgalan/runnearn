import { Component, ElementRef, HostListener, OnInit, ViewChild, AfterViewInit, OnDestroy, PLATFORM_ID, Inject } from '@angular/core';
import { CommonModule, isPlatformBrowser } from '@angular/common';

@Component({
    selector: 'app-interactive-background',
    standalone: true,
    imports: [CommonModule],
    template: `<canvas #canvas></canvas>`,
    styles: [`
    :host {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      z-index: 0;
      pointer-events: none; 
    }
    canvas {
      display: block;
      width: 100%;
      height: 100%;
    }
  `]
})
export class InteractiveBackgroundComponent implements AfterViewInit, OnDestroy {
    @ViewChild('canvas') canvasRef!: ElementRef<HTMLCanvasElement>;

    private ctx!: CanvasRenderingContext2D;
    private animationFrameId: number = 0;
    private particles: Particle[] = [];
    private mouse = { x: 0, y: 0, radius: 150 };
    private width = 0;
    private height = 0;
    private isBrowser: boolean;

    constructor(@Inject(PLATFORM_ID) platformId: Object) {
        this.isBrowser = isPlatformBrowser(platformId);
    }

    ngAfterViewInit() {
        if (this.isBrowser) {
            this.initCanvas();
            this.animate();
        }
    }

    ngOnDestroy() {
        if (this.isBrowser) {
            cancelAnimationFrame(this.animationFrameId);
            window.removeEventListener('resize', this.onResize);
            window.removeEventListener('mousemove', this.onMouseMove);
        }
    }

    private initCanvas() {
        this.ctx = this.canvasRef.nativeElement.getContext('2d')!;
        this.resize();
        this.createParticles();

        window.addEventListener('resize', this.onResize.bind(this));
        window.addEventListener('mousemove', this.onMouseMove.bind(this));
    }

    private onResize() {
        this.resize();
        this.createParticles();
    }

    private resize() {
        this.width = window.innerWidth;
        this.height = window.innerHeight;
        this.canvasRef.nativeElement.width = this.width;
        this.canvasRef.nativeElement.height = this.height;
    }

    private onMouseMove(e: MouseEvent) {
        this.mouse.x = e.x;
        this.mouse.y = e.y;
    }

    private createParticles() {
        this.particles = [];
        const particleCount = (this.width * this.height) / 9000;

        for (let i = 0; i < particleCount; i++) {
            this.particles.push(new Particle(this.width, this.height));
        }
    }

    private animate() {
        this.ctx.clearRect(0, 0, this.width, this.height);

        this.connectParticles();

        this.particles.forEach(particle => {
            particle.update(this.mouse);
            particle.draw(this.ctx);
        });

        this.animationFrameId = requestAnimationFrame(this.animate.bind(this));
    }

    private connectParticles() {
        const maxDistance = 120;

        for (let a = 0; a < this.particles.length; a++) {
            for (let b = a; b < this.particles.length; b++) {
                const dx = this.particles[a].x - this.particles[b].x;
                const dy = this.particles[a].y - this.particles[b].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < maxDistance) {
                    const opacity = 1 - (distance / maxDistance);
                    this.ctx.strokeStyle = `rgba(255, 107, 0, ${opacity * 0.2})`;
                    this.ctx.lineWidth = 1;
                    this.ctx.beginPath();
                    this.ctx.moveTo(this.particles[a].x, this.particles[a].y);
                    this.ctx.lineTo(this.particles[b].x, this.particles[b].y);
                    this.ctx.stroke();
                }
            }
        }
    }
}

class Particle {
    x: number;
    y: number;
    directionX: number;
    directionY: number;
    size: number;
    color: string;
    baseX: number;
    baseY: number;
    density: number;

    constructor(width: number, height: number) {
        this.x = Math.random() * width;
        this.y = Math.random() * height;
        this.directionX = (Math.random() * 0.4) - 0.2;
        this.directionY = (Math.random() * 0.4) - 0.2;
        this.size = Math.random() * 3 + 1;
        this.color = Math.random() > 0.5 ? '#FF6B00' : '#2E86DE';
        this.baseX = this.x;
        this.baseY = this.y;
        this.density = (Math.random() * 30) + 1;
    }

    draw(ctx: CanvasRenderingContext2D) {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2, false);
        ctx.fillStyle = this.color;
        ctx.fill();
    }

    update(mouse: { x: number, y: number, radius: number }) {
        // Check mouse proximity
        let dx = mouse.x - this.x;
        let dy = mouse.y - this.y;
        let distance = Math.sqrt(dx * dx + dy * dy);
        const forceDirectionX = dx / distance;
        const forceDirectionY = dy / distance;
        const maxDistance = mouse.radius;
        let force = (maxDistance - distance) / maxDistance;
        let directionX = forceDirectionX * force * this.density;
        let directionY = forceDirectionY * force * this.density;

        if (distance < mouse.radius) {
            this.x -= directionX;
            this.y -= directionY;
        } else {
            if (this.x !== this.baseX) {
                let dx = this.x - this.baseX;
                this.x -= dx / 20;
            }
        }
        this.x += this.directionX;
        this.y += this.directionY;

        if (this.x > window.innerWidth || this.x < 0) this.directionX = -this.directionX;
        if (this.y > window.innerHeight || this.y < 0) this.directionY = -this.directionY;
    }
}
