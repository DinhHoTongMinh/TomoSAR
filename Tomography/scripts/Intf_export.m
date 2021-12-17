function [] = Intf_export(infstack,inflist, Path,extention)

[nlines,nwidths,n_interf] = size(infstack);

real_index = 1:2:nwidths*2-1;
imag_index = 2:2:nwidths*2;
line_cpx = zeros(2*nwidths, 1); 

for i = 1:n_interf  
    filename = [Path,'/',num2str(inflist(i,1)),'_',num2str(inflist(i,2)),extention];
    fid = fopen(filename, 'wb', 'ieee-be');
    data = squeeze(infstack(:,:,i));
    for k=1:nlines
        line_cpx(real_index) = real(data(k,:));
        line_cpx(imag_index) = imag(data(k,:));
        write_count = fwrite(fid, line_cpx, 'float32');
        if (write_count ~= nwidths*2)
            error('ERROR: line %d: %d samples written instead of %d !', k, write_count, nwidths*2);
        end
    end
    fclose(fid);
end
                
