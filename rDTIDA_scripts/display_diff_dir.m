function  display_diff_dir( procparfile )
%display_diff_dir Displays in 3D the directions of the applied diffusion
%gradients


p=readprocpar(procparfile);

figure(1)
hold on
[x, y, z]=sphere;
r=0.2;
surf(x*r, y*r, z*r);

l=length(p.dro);
quiver3(zeros(1,l),zeros(1,l),zeros(1,l),p.dro,p.dsl,p.dpe)

axis equal
end

