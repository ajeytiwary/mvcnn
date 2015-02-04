function imdb = clipart_get_database(clipartDir, varargin)
% Set the random seed generator
opts.seed = 0 ;
opts = vl_argparse(opts, varargin) ;
rng(opts.seed) ;

imdb.imageDir = fullfile(clipartDir);
fid = fopen(fullfile(clipartDir, 'classlist.txt'));
classlist = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

% Images and class
imdb.classes.name = classlist{1}';
imdb.images.name = {};
for c = imdb.classes.name, 
    c = c{:};
    filelist = dir(fullfile(clipartDir,c,'*.png'));
    imagePaths = cellfun(@(x) fullfile(c,x),{filelist.name},'UniformOutput',false);
    imdb.images.name = [imdb.images.name,imagePaths];
end
imdb.images.id = 1:length(imdb.images.name);
class = cellfun(@(x) fileparts(x), imdb.images.name, 'UniformOutput', false);

% Class names
[~, imdb.images.label] = ismember(class, imdb.classes.name);

% No standard image splits are provided for this dataset, so split them
% randomly into equal sized train/val/test sets
imdb.sets = {'train', 'val', 'test'};
imdb.images.set = zeros(1,length(imdb.images.id));
for c = 1:length(imdb.classes.name), 
    isclass = find(imdb.images.label == c);
    
    % split equally into train, val, test
    order = randperm(length(isclass));
    subsetSize = ceil(length(order)/3);
    train = isclass(order(1:subsetSize));
    val = isclass(order(subsetSize+1:2*subsetSize));
    test  = isclass(order(2*subsetSize+1:end));
    
    imdb.images.set(train) = 1;
    imdb.images.set(val) = 2;
    imdb.images.set(test) = 3;
end
